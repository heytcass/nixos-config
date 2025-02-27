# NixOS system configuration
# See configuration.nix(5) and nixos-help for more details

{ config, pkgs, inputs, ... }:

{
  imports = [ 
    # Include the results of the hardware scan
    ./hardware-configuration.nix
  ];

  #######################
  # SYSTEM CONFIGURATION
  #######################

  # System basics
  system.stateVersion = "24.11";  # Required by NixOS, do not change
  nixpkgs.config.allowUnfree = true;

  # Nix package manager configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Boot configuration
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    plymouth.enable = true;
  };

  #######################
  # NETWORKING
  #######################

  networking = {
    hostName = "gti";
    networkmanager.enable = true;
  };

  #######################
  # LOCALIZATION
  #######################

  # Time zone and locale settings
  time.timeZone = "America/Detroit";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
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

  #######################
  # DESKTOP ENVIRONMENT
  #######################

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
    pkgs.gnome-tour
    pkgs.gnome.geary
    pkgs.gnome.epiphany  # GNOME Web browser
  ];
  
  # Disable NixOS documentation
  documentation.nixos.enable = false;

  #######################
  # AUDIO
  #######################

  # Pipewire sound system
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    pulse.enable = true;
  };

  #######################
  # USERS
  #######################

  users.users.tom = {
    isNormalUser = true;
    description = "Tom Cassady";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    # User-specific packages are managed in home.nix
  };

  #######################
  # PACKAGES & FONTS
  #######################

  # System-wide packages - only essential system tools
  environment.systemPackages = with pkgs; [
    git  # Keep git at system level for easy management of your flake repo
  ];

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  #######################
  # DISABLED SERVICES
  #######################

  # Uncomment to enable kmscon terminal
  # services.kmscon.enable = true;
}