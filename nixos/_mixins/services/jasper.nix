{ inputs, pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.jasperCompanion;
in
{
  # Define the jasper service options directly
  options.services.jasperCompanion = {
    enable = mkEnableOption "Jasper Companion personal assistant";
    
    package = mkOption {
      type = types.package;
      default = inputs.jasper.packages.${pkgs.system}.default;
      description = "Jasper Companion package to use";
    };
    
    user = mkOption {
      type = types.str;
      description = "User under which Jasper Companion runs";
    };
  };
  
  config = mkMerge [
    {
      # Enable the service
      services.jasperCompanion = {
        enable = true;
        user = "tom";
      };
    }
    (mkIf cfg.enable {
      # User systemd service (runs as user, not system service)
      systemd.user.services.jasper-companion = {
        description = "Jasper Companion Personal Assistant";
        after = [ "graphical-session.target" ];
        wantedBy = [ "default.target" ];
        
        serviceConfig = {
          Type = "simple";
          ExecStart = "${cfg.package}/bin/jasper-companion-daemon";
          Restart = "on-failure";
          RestartSec = 10;
          
          # Add common binary paths
          Environment = [
            "PATH=/run/current-system/sw/bin:/usr/local/bin:/home/tom/.local/bin:$PATH"
          ];
          
          # Security hardening for user service
          PrivateTmp = true;
          ProtectSystem = "strict";
          ProtectHome = false;  # Need access to user config
          ReadWritePaths = [
            "%h/.config/jasper-companion"
            "%h/.local/share/jasper-companion"
          ];
        };
      };
      
      # Add package to system packages
      environment.systemPackages = [ cfg.package ];
    })
  ];
}