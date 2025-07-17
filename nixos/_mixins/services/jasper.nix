{ inputs, pkgs, lib, config, ... }:

with lib;

let
  cfg = config.services.jasperCompanion;
  
  # Create a script that looks for jasper-companion-daemon in PATH
  jasperWrapper = pkgs.writeShellScriptBin "jasper-companion-daemon" ''
    # Look for jasper-companion-daemon in PATH
    if command -v jasper-companion-daemon >/dev/null 2>&1; then
      exec jasper-companion-daemon "$@"
    else
      echo "❌ Jasper daemon not found in PATH"
      echo "💡 To install Jasper:"
      echo "   1. cd /home/tom/git/jasper"
      echo "   2. nix build"
      echo "   3. sudo cp result/bin/jasper-companion-daemon /usr/local/bin/"
      echo "   4. systemctl --user restart jasper-companion"
      exit 1
    fi
  '';
in
{
  # Define the jasper service options directly
  options.services.jasperCompanion = {
    enable = mkEnableOption "Jasper Companion personal assistant";
    
    package = mkOption {
      type = types.package;
      default = jasperWrapper;
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