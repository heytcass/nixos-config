{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.network = {
    enable = mkEnableOption "network configuration";
    
    hostName = mkOption {
      type = types.str;
      default = "nixos";
      description = "The hostname of the machine";
    };

    networkmanager = {
      enable = mkEnableOption "NetworkManager";
    };

    # You might want these later, so I'll include them commented out
    # firewall = {
    #   enable = mkEnableOption "firewall configuration";
    #   tcpPorts = mkOption {
    #     type = types.listOf types.port;
    #     default = [];
    #     description = "List of allowed TCP ports";
    #   };
    #   udpPorts = mkOption {
    #     type = types.listOf types.port;
    #     default = [];
    #     description = "List of allowed UDP ports";
    #   };
    # };
  };

  config = mkIf config.modules.network.enable {
    networking = {
      hostName = config.modules.network.hostName;
      networkmanager.enable = config.modules.network.networkmanager.enable;
    };

    # Firewall configuration for later use
    # networking.firewall = mkIf config.modules.network.firewall.enable {
    #   enable = true;
    #   allowedTCPPorts = config.modules.network.firewall.tcpPorts;
    #   allowedUDPPorts = config.modules.network.firewall.udpPorts;
    # };
  };
}