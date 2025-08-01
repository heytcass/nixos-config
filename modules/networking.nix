{ config, pkgs, lib, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
  
  # DNS servers (Cloudflare and Google)
  dnsServers = [ "1.1.1.1" "8.8.8.8" ];
  
  # KDE Connect port ranges for local discovery
  kdeConnectPorts = { from = 1714; to = 1764; };
in
{
  networking = {
    hostName = shared.hardware.hostname;
    
    # Network management with performance tuning
    networkmanager = {
      enable = true;
      wifi.powersave = false;  # Prioritize performance over battery
    };
    
    # DNS configuration
    nameservers = dnsServers;
    
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
      domains = [ "~." ];
      fallbackDns = dnsServers;
      dnsovertls = "opportunistic";
    };
    
    # Network time synchronization
    ntp.enable = false;
    timesyncd.enable = true;
  };
}