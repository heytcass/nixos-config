# Common configuration for all hosts
{ config, pkgs, lib, inputs, ... }:

{
  # System basics
  system.stateVersion = "24.11";  # Required by NixOS, do not change
  nixpkgs.config.allowUnfree = true;

  # Nix package manager configuration
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = [ "flakes" "nix-command" ];
    download-buffer-size = 10485760; # 10 MiB (default is 1 MiB)
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
    slack  # Communication platform
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs  # Claude Desktop with FHS support
    nodejs # For Claude Desktop
  ];

  # Run nixos-needsreboot after each rebuild
  system.activationScripts.nixos-needsreboot = {
    text = ''
      echo "Checking if reboot is needed..."
      ${pkgs.lib.getExe inputs.nixos-needsreboot.packages.${pkgs.system}.default} || true
    '';
    deps = [];
  };

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # Enable Wayland support for Electron apps like Slack
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}