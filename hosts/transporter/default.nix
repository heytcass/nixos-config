# Host-specific configuration for transporter (Dell Latitude 7280)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../common/optional/gnome.nix  # Keep GNOME too for fallback
    ../common/optional/hyprland.nix
  ];

  # Host-specific settings
  networking.hostName = "transporter";
  
  # Hyprland testing environment
  environment.systemPackages = with pkgs; [
    swww          # Wallpaper for Hyprland
    wofi          # App launcher for Hyprland
    mako          # Notification daemon
    wlsunset      # Blue light filter
    swaylock      # Screen locker
    swayidle      # Idle management
  ];
  
  # Enable Hyprland in Home Manager for tom user
  home-manager.users.tom = { pkgs, config, lib, ... }: {
    # Override default values in the shared config
    wayland.windowManager.hyprland.enable = lib.mkForce true;
    programs.wofi.enable = lib.mkForce true;
    
    # Additional Hyprland-specific packages for tom
    home.packages = with pkgs; [
      swww
      wl-clipboard
    ];
  };
}