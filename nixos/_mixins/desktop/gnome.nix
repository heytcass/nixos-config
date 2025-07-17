# GNOME desktop environment mixin
# Provides GNOME desktop with customizations and optimizations

{
  pkgs,
  ...
}:

{
  imports = [
    ./common.nix
  ];

  # GNOME-specific desktop environment configuration
  services.desktopManager.gnome.enable = true;

  # Override common display manager config for GNOME
  services.displayManager.gdm.wayland = false; # GNOME handles Wayland internally

  # GNOME customization
  environment = {
    gnome.excludePackages = with pkgs; [
      epiphany
      gnome-maps
      gnome-music
      gnome-tour
      gnome-terminal
      gnome-console
      simple-scan
      totem
      yelp
    ];

    systemPackages = with pkgs; [
      gnomeExtensions.user-themes
      gnomeExtensions.appindicator
      gnomeExtensions.vitals
      gnomeExtensions.pop-shell
      gnomeExtensions.blur-my-shell

      # Icon themes
      papirus-icon-theme
      papirus-folders
      tela-icon-theme

      # Customization tools
      gnome-extension-manager
      gnome-tweaks

      # Desktop applications
      teams-for-linux
    ];
  };
}
