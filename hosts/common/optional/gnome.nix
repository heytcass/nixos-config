# GNOME Desktop Environment Configuration
{ config, pkgs, lib, ... }:

{
  # X11 and GNOME
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Keyboard settings
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };
  
  # Exclude XTerm
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Exclude unwanted GNOME packages
  environment.gnome.excludePackages = [
    pkgs.epiphany        # GNOME Web browser
    pkgs.geary           # Email client
    pkgs.gnome-console   # Terminal (using Ghostty instead)
    pkgs.gnome-maps      # Maps application
    pkgs.gnome-music     # Music player
    pkgs.gnome-tour
    pkgs.simple-scan     # Document scanner
    pkgs.totem           # Video player
    pkgs.yelp            # Help viewer
  ];

  # Disable NixOS documentation
  documentation.nixos.enable = false;
}