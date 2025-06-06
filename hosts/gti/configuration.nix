{
  config,
  pkgs,
  inputs,
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
    settings = {
      experimental-features = [ "flakes" "nix-command" ];
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      auto-optimise-store = true;
      builders-use-substitutes = true;
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # Time zone
  time.timeZone = "America/Detroit";

  # Graphics and Gaming
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Audio
  security.rtkit.enable = true;

  # Programs
  programs = {
    fish.enable = true;
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };    
  };

  # Services
  services = {
    desktopManager.gnome.enable = true;
    displayManager.gdm.enable = true;
    fwupd.enable = true;
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
    sessionVariables = {
      NIXOS_OZONE_WL = "1";
      ELECTRON_OZONE_PLATFORM_HINT = "auto";
    };
    systemPackages = with pkgs; [
      fwupd-efi
      gnome-firmware
      gnomeExtensions.user-themes
      gnomeExtensions.appindicator
      gnomeExtensions.vitals
      gnomeExtensions.pop-shell
      gnomeExtensions.blur-my-shell
      gnomeExtensions.solaar-extension
      logitech-udev-rules
      solaar
      
      # Claude Desktop with FHS for MCP servers
      inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
    ];
  };

  # Users
  users.users.tom = {
    description = "Tom Cassady";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    isNormalUser = true;
    shell = pkgs.fish;
    packages = with pkgs; [
      bitwarden-desktop
      claude-code
      google-chrome
      slack
      zoom-us
    ];
  };

  system.stateVersion = "25.05";
}