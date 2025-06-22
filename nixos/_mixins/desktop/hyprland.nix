# Hyprland desktop environment mixin
# Provides modern Wayland compositor with optimizations and essential tools

{ config, pkgs, lib, inputs, ... }:

{
  # Hyprland window manager
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # X11 server for XWayland compatibility
  services.xserver = {
    enable = true;
    excludePackages = [ pkgs.xterm ];
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };

  # Display manager - GDM works well with Hyprland
  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  # Fonts (same as GNOME for consistency)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  # Essential Wayland packages for modern desktop experience
  environment.systemPackages = with pkgs; [
    # Modern Wayland-native tools
    wofi              # Rust-based launcher (replaces rofi)
    waybar            # Modern status bar
    swaylock-effects  # Screen locker with effects
    mako              # Rust-based notification daemon
    grim              # Screenshot tool
    slurp             # Area selection for screenshots
    wl-clipboard      # Wayland clipboard utilities
    swayidle          # Idle management daemon
    swaybg            # Wallpaper daemon
    wlr-randr         # Display configuration
    kanshi            # Dynamic display configuration
    
    # File management and media
    thunar            # Lightweight file manager (Hyprland-only)
    thunar-volman     # Volume management for thunar
    xfce.tumbler      # Thumbnail support for thunar
    imv               # Wayland-native image viewer
    mpv               # Video player with Wayland support
    
    # System utilities
    brightnessctl     # Brightness control
    playerctl         # Media player control
    pavucontrol       # PulseAudio/PipeWire volume control
    
    # Development and terminal tools
    wev               # Wayland event viewer (for debugging)
  ];

  # Security and authentication
  security = {
    polkit.enable = true;
    pam.services.swaylock = {};
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

  # Environment variables for Wayland
  environment.sessionVariables = {
    # Existing Wayland variables are already set in base.nix
    # Just add Hyprland-specific ones
    WLR_NO_HARDWARE_CURSORS = "1";  # Fix cursor issues on some hardware
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
    XDG_SESSION_TYPE = "wayland";
  };

  # Enable hardware acceleration (already handled in base.nix)
  # Ensure proper graphics drivers are loaded
  hardware.graphics.enable = true;
  
  # Printing disabled by default (same as GNOME mixin)
  services.printing.enable = false;
}