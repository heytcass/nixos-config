# Configuration for Dell Latitude 7280 (transporter)
# Separate configuration to avoid conflicts with XPS 13 9370

{ config, pkgs, lib, notion-mac-flake, claude-desktop-linux-flake, sops-nix, nix-output-monitor, ... }:

let
  # Same trusted binary cache sources
  substituters = [
    "https://cache.nixos.org/"
    "https://nix-community.cachix.org"
  ];
  
  trustedPublicKeys = [
    "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
  
  nixSettings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
    trusted-users = [ "root" config.mySystem.user.name ];
    substituters = substituters;
    trusted-public-keys = trustedPublicKeys;
  };
in
{
  imports = [
    ./hardware/transporter-hardware-configuration.nix
    ./modules/options.nix
    ./modules/boot.nix
    ./modules/hardware.nix
    ./modules/desktop.nix
    ./modules/networking.nix
    ./modules/security.nix
    ./modules/performance.nix
    ./modules/systemd.nix
    { _module.args = { inherit notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor; }; }
    ./modules/tools.nix
    ./modules/secrets.nix
    ./modules/post-install.nix
    # Skip secure-boot.nix for test system
    ./modules/advanced-tools.nix
    ./modules/oomd.nix
  ];

  # System version
  system.stateVersion = "25.05";

  # Localization
  time.timeZone = config.mySystem.hardware.timezone;
  i18n.defaultLocale = config.mySystem.hardware.locale;

  # Package and system management
  nixpkgs.config.allowUnfree = true;
  
  nix = {
    settings = nixSettings;
    gc = {
      automatic = true; 
      dates = "weekly";
      options = "--delete-older-than ${config.mySystem.security.gcRetentionDays}";
    };
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # Container platform with enhanced security
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
    
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };
  
  # Rootless container support
  virtualisation.containers = {
    enable = true;
    registries.search = [ "docker.io" "quay.io" ];
    policy = {
      default = [ { type = "insecureAcceptAnything"; } ];
      transports = {
        docker-daemon = {
          "" = [ { type = "insecureAcceptAnything"; } ];
        };
      };
    };
  };

  # System services
  programs.dconf.enable = true;

  # User account
  users.users.${config.mySystem.user.name} = {
    isNormalUser = true;
    description = config.mySystem.user.fullName;
    shell = config.mySystem.user.shell;
    extraGroups = config.mySystem.user.groups;
  };
}