# Hyprland desktop environment mixin
# Provides modern Wayland compositor with optimizations and essential tools

{
  pkgs,
  inputs,
  ...
}:

{
  # Hyprland window manager
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # Environment configuration consolidated
  environment = {
    # Essential Wayland packages for modern desktop experience
    systemPackages = with pkgs; [
      # Official Hyprland ecosystem tools (from nixpkgs)
      hyprpaper # Official wallpaper utility
      hyprpicker # Official color picker
      hyprlock # GPU-accelerated screen locker
      hypridle # Official idle management
      hyprsunset # Blue light filter

      # Modern Wayland-native tools
      wofi # Rust-based launcher (replaces rofi)
      waybar # Modern status bar
      swaynotificationcenter # Modern notification center
      grim # Screenshot tool
      slurp # Area selection for screenshots
      wl-clipboard # Wayland clipboard utilities
      wlr-randr # Display configuration
      kanshi # Dynamic display configuration

      # File management and media
      xfce.thunar # Lightweight file manager (Hyprland-only)
      xfce.thunar-volman # Volume management for thunar
      xfce.tumbler # Thumbnail support for thunar
      imv # Wayland-native image viewer
      mpv # Video player with Wayland support

      # System utilities
      brightnessctl # Brightness control
      playerctl # Media player control
      pavucontrol # PulseAudio/PipeWire volume control

      # Development and terminal tools
      wev # Wayland event viewer (for debugging)
    ];

    # Environment variables for Wayland
    sessionVariables = {
      # Existing Wayland variables are already set in base.nix
      # Just add Hyprland-specific ones
      WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor issues on some hardware
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  # Services configuration consolidated
  services = {
    # X11 server for XWayland compatibility
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xkb = {
        layout = "us";
        variant = "colemak";
      };
    };

    # Display manager - GDM works well with Hyprland
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Printing disabled by default (same as GNOME mixin)
    printing.enable = false;
  };

  # Security and authentication
  security = {
    polkit.enable = true;
    pam.services.swaylock = { };
  };

  # XDG Portal for proper Wayland app integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
  };

  # Hardware acceleration is handled in base.nix
}
