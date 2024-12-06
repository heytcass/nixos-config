{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.hyprland = {
    enable = mkEnableOption "Hyprland configuration";

    wallpaper = {
      enable = mkEnableOption "wallpaper support";
      path = mkOption {
        type = types.str;
        default = "";
        description = "Path to wallpaper image";
      };
    };

    monitors = mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = mkOption {
            type = types.str;
            description = "Monitor identifier (e.g., DP-1)";
          };
          resolution = mkOption {
            type = types.str;
            description = "Resolution and refresh rate (e.g., 1920x1080@144)";
          };
          position = mkOption {
            type = types.str;
            description = "Position (e.g., 0x0)";
          };
          scale = mkOption {
            type = types.float;
            default = 1.0;
            description = "Scale factor for the monitor";
          };
        };
      });
      default = [];
      description = "Monitor configuration";
    };

    theme = {
      colors = {
        background = mkOption {
          type = types.str;
          default = "rgb(1d1f21)";
          description = "Background color";
        };
        foreground = mkOption {
          type = types.str;
          default = "rgb(c5c8c6)";
          description = "Foreground color";
        };
        accent = mkOption {
          type = types.str;
          default = "rgb(81a2be)";
          description = "Accent color";
        };
      };
    };
  };

  config = mkIf config.modules.hyprland.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    environment = {
      sessionVariables = {
        NIXOS_OZONE_WL = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_SESSION_DESKTOP = "Hyprland";
        XDG_CURRENT_DESKTOP = "Hyprland";
      };

      systemPackages = with pkgs; [
        # Core components
        waybar           # Status bar
        wofi             # Application launcher
        dunst           # Notification daemon
        swaylock-effects # Screen locker with effects
        swayidle        # Idle management daemon
        wl-clipboard    # Clipboard utilities
        
        # Screenshot and recording
        grim            # Screenshot utility
        slurp           # Screen area selection
        wf-recorder     # Screen recording

        # System interfacing tools
        brightnessctl   # Brightness control
        pamixer         # PulseAudio command line mixer
        pavucontrol     # PulseAudio volume control
        
        # System information
        btop            # System monitor
        
        # File management
        xfce.thunar     # File manager
        
        # Additional utilities
        wev             # Input event viewer
        wlr-randr       # xrandr for wayland
      ] ++ (optionals config.modules.hyprland.wallpaper.enable [
        swaybg          # Wallpaper utility
      ]);
    };

    # Add user to required groups
    users.users.${config.modules.users.mainUser.name}.extraGroups = [ 
      "video" 
      "input"
    ];

    # Optional: Enable services commonly used with Hyprland
    security.pam.services.swaylock = {}; # Required for swaylock
  };
}