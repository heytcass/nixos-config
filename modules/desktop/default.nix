{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop = {
    enable = mkEnableOption "desktop environment";
    
    environment = mkOption {
      type = types.enum [ "gnome" "hyprland" ];
      default = "gnome";
      description = "Desktop environment to use";
    };
    
    keyboard = {
      layout = mkOption {
        type = types.str;
        default = "us";
        description = "Keyboard layout";
      };
      
      variant = mkOption {
        type = types.str;
        default = "colemak";
        description = "Keyboard variant";
      };
    };
  };

  config = mkIf config.modules.desktop.enable (mkMerge [
    # Common configuration for all desktop environments
    {
      # X11 base configuration
      services.xserver = {
        enable = true;
        excludePackages = [ pkgs.xterm ];
        
        # Keyboard settings from module options
        xkb = {
          layout = config.modules.desktop.keyboard.layout;
          variant = config.modules.desktop.keyboard.variant;
        };
      };

      # Hardware-related services that are DE-independent
      services.fwupd.enable = true;
      services.hardware.bolt.enable = true;
      services.printing.enable = false;
    }

    # GNOME-specific configuration
    (mkIf (config.modules.desktop.environment == "gnome") {
      services.xserver = {
        displayManager.gdm.enable = true;
        desktopManager.gnome.enable = true;
      };
      services.gnome.core-utilities.enable = true;

      # Add system tray support
      services.udev.packages = with pkgs; [ gnome-settings-daemon ];
      environment.systemPackages = with pkgs; [
        gnomeExtensions.appindicator  # Add system tray support
      ];

      # Remove default GNOME applications
      environment.gnome.excludePackages = (with pkgs; [
        epiphany
        evince
        geary
        gnome-music
        gnome-photos
        gnome-tour
        gnome-weather
      ]);
    })

    # Hyprland-specific configuration
    (mkIf (config.modules.desktop.environment == "hyprland") {
      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
      };

      # Common Wayland-related packages you might want
      environment.systemPackages = with pkgs; [
        waybar           # Status bar
        wofi             # Application launcher
        dunst           # Notification daemon
        swaylock        # Screen locker
        swayidle        # Idle management daemon
        grim            # Screenshot utility
        slurp           # Screen area selection
        wl-clipboard    # Clipboard utilities
        kitty
      ];

      # Wayland-specific settings
      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";  # Electron apps use Wayland
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "Hyprland";
        XDG_SESSION_DESKTOP = "Hyprland";
      };

      # Consider using a Wayland-native display manager
      services.xserver.displayManager.gdm = {
        enable = true;
        wayland = true;
      };
    })
  ]);
}