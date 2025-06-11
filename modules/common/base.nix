{
  config,
  pkgs,
  lib,
  ...
}: {
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

  # Disable nano system-wide in favor of micro
  environment.defaultPackages = with pkgs; lib.mkForce [
    # Default packages except nano
    coreutils
    curl
    diffutils
    findutils
    gawk
    gnutar
    gzip
    gnugrep
    gnused
    systemd
    util-linux
    which
    xz
  ];

  # Time zone
  time.timeZone = "America/Detroit";

  # Graphics and Hardware
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Laptop optimizations
  powerManagement = {
    enable = true;
    powertop.enable = true;
  };

  services = {
    # Power management - disable power-profiles-daemon when using TLP
    power-profiles-daemon.enable = false;
    tlp = {
      enable = true;
      settings = {
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        
        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
        
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;
        
        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;
        
        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };

    # Thermal management
    thermald.enable = true;

    # Firmware updates
    fwupd.enable = true;

    # Auto-mount USB devices
    udisks2.enable = true;
  };

  # Network management
  networking.networkmanager.enable = true;

  # Audio
  security.rtkit.enable = true;
  services = {
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
    };
    pulseaudio.enable = false;
  };

  # Environment variables for better laptop experience
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # Common system packages
  environment.systemPackages = with pkgs; [
    # Hardware utilities
    fwupd-efi
    gnome-firmware
    
    # Logitech device support
    gnomeExtensions.solaar-extension
    logitech-udev-rules
    solaar
  ];
}