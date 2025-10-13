{ config, pkgs, lib, ... }:

let
  # KDE Connect port ranges for local discovery
  kdeConnectPorts = { from = 1714; to = 1764; };
in
{
  networking = {
    hostName = config.mySystem.hardware.hostname;

    # Network management with performance tuning
    networkmanager = {
      enable = true;
      wifi.powersave = false; # Prioritize performance over battery
    };


    # Firewall with minimal necessary ports
    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      allowedTCPPortRanges = [ kdeConnectPorts ];
      allowedUDPPortRanges = [ kdeConnectPorts ];
    };
  };

  services = {
    # Modern DNS resolution with security
    resolved = {
      enable = true;
      dnssec = "true";
      dnsovertls = "opportunistic";
    };

    # Network time synchronization
    ntp.enable = false;
    timesyncd.enable = true;
  };
}
