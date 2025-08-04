{ config, pkgs, lib, ... }:
{
  # Systemd user services and D-Bus integration
  services = {
    # D-Bus integration for desktop applications
    dbus = {
      enable = true;
      packages = with pkgs; [ 
        dconf 
        gnome-settings-daemon 
      ];
    };
  };

  # Enable user lingering for containers (declarative)
  users.users.${config.mySystem.user.name}.linger = true;

  # Enable systemd user services
  systemd.user = {
    # User service for automatic system optimization
    services.nix-optimize = {
      description = "Optimize Nix store";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.nix}/bin/nix store optimise";
      };
    };
    
    # Timer for periodic optimization
    timers.nix-optimize = {
      description = "Run Nix store optimization weekly";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "weekly";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };

  # User environment variables for better integration
  environment.sessionVariables = {
    # XDG directories for proper desktop integration
    XDG_DATA_DIRS = [
      "/usr/share" 
      "/usr/local/share"
      "/var/lib/flatpak/exports/share"
      "/home/${config.mySystem.user.name}/.local/share/flatpak/exports/share"
    ];
  };

  # Advanced logging configuration
  services.journald = {
    extraConfig = ''
      SystemMaxUse=${config.mySystem.security.journalMaxSize}
      RuntimeMaxUse=${config.mySystem.security.runtimeMaxSize}
      MaxRetentionSec=1month
      MaxFileSec=1week
      ForwardToSyslog=no
      ForwardToWall=no
    '';
  };

  # Systemd configuration improvements
  systemd = {
    # Faster service timeouts
    settings.Manager = {
      DefaultTimeoutStopSec = "10s";
    };
    
    # User service configuration
    user.extraConfig = ''
      DefaultTimeoutStopSec=10s
    '';
  };
}