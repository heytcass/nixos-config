# Network services configuration
# Conditional network services based on system needs

{
  lib,
  isISO,
  isWorkstation,
  ...
}:

{
  # Tailscale VPN - conditional based on system type
  services.tailscale = {
    enable = lib.mkIf (!isISO && isWorkstation) true;
    useRoutingFeatures = lib.mkIf (!isISO && isWorkstation) "client";
    extraUpFlags = lib.mkIf (!isISO && isWorkstation) [
      "--ssh"
      "--accept-routes"
    ];
  };

  # NetworkManager - essential for all non-ISO systems
  networking = {
    networkmanager = {
      enable = lib.mkIf (!isISO) true;
      wifi.powersave = lib.mkIf (!isISO) true;
    };

    # Firewall configuration
    firewall = {
      enable = lib.mkDefault true;
      allowedTCPPorts = lib.mkIf (!isISO) [ 22 ]; # SSH
      checkReversePath = lib.mkDefault "loose"; # For Tailscale
    };
  };
}
