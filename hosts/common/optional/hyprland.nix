# Hyprland Window Manager Configuration - System Level Settings
{ config, pkgs, lib, ... }:

{
  # Enable XServer with GDM
  services.xserver = {
    enable = true;
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Keyboard settings - consistent with GNOME setup
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };
  
  # XDG Desktop Portal for screen sharing and file picking
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-hyprland
      pkgs.xdg-desktop-portal-gtk
    ];
  };
  
  # Core system-level Hyprland dependencies
  environment.systemPackages = with pkgs; [
    # Core Wayland utilities
    wl-clipboard     # Clipboard manager
    grim             # Screenshot utility
    slurp            # Area selection tool
    
    # Other utilities
    brightnessctl    # Brightness control
    pamixer          # Volume control
    networkmanagerapplet # Network management
  ];

  # Enable polkit for GUI permission prompts
  security.polkit.enable = true;
  
  # Use keyring for credentials
  services.gnome.gnome-keyring.enable = true;
  
  # Enable sound for Hyprland
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };
}