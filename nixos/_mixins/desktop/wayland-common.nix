# Common Wayland packages shared across desktop environments
# This module provides the core Wayland utilities needed by both Hyprland and Niri

{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    wofi # Rust-based launcher (replaces rofi)
    waybar # Modern status bar
    swaynotificationcenter # Modern notification center
    grim # Screenshot tool
    slurp # Area selection for screenshots
    wl-clipboard # Wayland clipboard utilities
    wlr-randr # Display configuration
    kanshi # Dynamic display configuration

    # File management and media
    xfce.thunar # Lightweight file manager
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
}