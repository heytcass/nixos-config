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
    auto-optimise-store = true;
    experimental-features = [ "flakes" "nix-command" ];
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
  
  # Tailscale VPN
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "client"; # Enable subnet routing
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
    description = "Tom Cassady";
    extraGroups = [ "dialout" "networkmanager" "wheel" ];
    isNormalUser = true;
    # User-specific packages are managed in home.nix
  };

  #######################
  # PACKAGES & FONTS
  #######################

  # System-wide packages - only essential system tools
  environment.systemPackages = with pkgs; [
    git  # Keep git at system level for easy management of your flake repo
    inputs.fh.packages.${pkgs.system}.default  # FlakeHub CLI tool
    inputs.nixos-generators.packages.${pkgs.system}.default  # NixOS Generators
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
