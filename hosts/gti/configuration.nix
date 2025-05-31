{
  config,
  pkgs,
  ...
}: {
  imports = [ ./hardware-configuration.nix ];

  # Boot configuration
  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    plymouth.enable = true;
  };

  # Internationalization
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

  # Networking
  networking = {
    hostName = "gti";
    networkmanager.enable = true;
  };

  # Nix configuration
  nix = {
    settings.experimental-features = [ "flakes" "nix-command" ];
    optimise.automatic = true;
  };
  nixpkgs.config.allowUnfree = true;

  # Time zone
  time.timeZone = "America/Detroit";

  # Audio
  security.rtkit.enable = true;

  # Services
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    printing.enable = false;
    pulseaudio.enable = false;
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

  # Environment
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
    sessionVariables.NIXOS_OZONE_WL = "1";
    systemPackages = with pkgs; [
      gnomeExtensions.user-themes
      gnomeExtensions.appindicator
      gnomeExtensions.vitals
      gnomeExtensions.pop-shell
      gnomeExtensions.blur-my-shell
    ];
  };

  # Users
  users.users.tom = {
    description = "Tom Cassady";
    extraGroups = [ "networkmanager" "wheel" ];
    isNormalUser = true;
    packages = with pkgs; [
      bitwarden-desktop
      claude-code
      google-chrome
      slack
    ];
  };

  system.stateVersion = "25.05";
}