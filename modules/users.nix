{ config, pkgs, ... }:

{
  users.users.tom = {
    isNormalUser = true;
    description = "Tom Cassady";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.nushell;  # Set nushell as the default shell
    packages = with pkgs; [
      # User-specific packages can go here
    ];
  };

  environment.systemPackages = with pkgs; [
    nushell
    starship
  ];

  # Font for symbols (needed for starship)
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  # Locale settings
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };
}
