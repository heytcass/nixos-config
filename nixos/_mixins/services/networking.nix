# Network services configuration
# Conditional network services based on system needs

{
  lib,
  isISO,
  isWorkstation,
  ...
}:

{
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

  # SSH server configuration with security hardening
  services.openssh = lib.mkIf (!isISO) {
    enable = true;
    settings = {
      # Disable root login
      PermitRootLogin = "no";
      # Only allow key-based authentication
      PasswordAuthentication = false;
      PubkeyAuthentication = true;
      # Disable X11 forwarding for security
      X11Forwarding = false;
      # Disable TCP forwarding
      AllowTcpForwarding = "no";
      # Client timeout settings
      ClientAliveInterval = 300;
      ClientAliveCountMax = 2;
      # Limit authentication attempts
      MaxAuthTries = 3;
      LoginGraceTime = 30;
      # Use SSH protocol 2 only
      Protocol = 2;
    };
    # Disable SFTP subsystem
    allowSFTP = false;
    # Additional security configuration
    extraConfig = ''
      AllowUsers tom
      DenyUsers root
    '';
  };
}
