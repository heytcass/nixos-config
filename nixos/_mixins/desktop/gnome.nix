# GNOME desktop environment mixin
# Provides GNOME desktop with customizations and optimizations

{
  pkgs,
  ...
}:

{
  # Desktop Environment
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;

    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xkb = {
        layout = "us";
        variant = "colemak";
      };
    };

    # Printing (disabled by default for laptops)
    printing.enable = false;
  };

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
    ];
  };
}
