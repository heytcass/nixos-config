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
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

  # GNOME customization
  environment = {
    gnome.excludePackages = with pkgs; [
      epiphany
      gnome-maps
      gnome-music
      gnome-tour
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
    ];
  };

  # Printing (disabled by default for laptops)
  services.printing.enable = false;
}
