# Tailscale secure mesh networking
# Provides zero-config VPN between devices

{
  config,
  lib,
  pkgs,
  isISO,
  ...
}:

{
  # Only enable Tailscale for non-ISO systems
  config = lib.mkIf (!isISO) {
    # Enable Tailscale service
    services.tailscale = {
      enable = true;
      useRoutingFeatures = "client"; # Enable subnet routing as client
    };

    # Firewall configuration for Tailscale
    networking.firewall = {
      # Allow Tailscale through firewall
      trustedInterfaces = [ "tailscale0" ];
      # Allow Tailscale UDP port (41641 by default)
      allowedUDPPorts = [ config.services.tailscale.port ];
      # Enable Tailscale's interface in trusted zones
      checkReversePath = "loose";
    };

    # Enable IP forwarding for subnet routing capabilities
    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
      "net.ipv6.conf.all.forwarding" = 1;
    };

    # Add Tailscale CLI to system packages
    environment.systemPackages = with pkgs; [
      tailscale
    ];

    # Systemd service optimizations
    systemd.services.tailscaled = {
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        # Restart on failure
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
