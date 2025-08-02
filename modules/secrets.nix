{ config, pkgs, lib, sops-nix, ... }:
{
  # Add sops and age packages
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];

  # sops-nix configuration
  sops = {
    # Default sops file location
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # Validate sops files at build time
    validateSopsFiles = false;  # Set to true once you have secrets
    
    # Age key configuration
    age = {
      # System secrets use SSH host key converted to age
      keyFile = "/var/lib/sops-nix/key.txt";
      generateKey = true;  # Auto-generate if doesn't exist
    };

    # System secrets - temporarily disabled until age keys are properly configured
    secrets = {
      # Commented out until decryption keys are set up properly
      # "wifi/home_password" = config.mySystem.secrets.system // { mode = "0440"; };
      # "services/github_token" = config.mySystem.secrets.development;
      # "services/openai_api_key" = config.mySystem.secrets.development;
      # "services/anthropic_api_key" = config.mySystem.secrets.development;
    };
  };

  # Create initial age key directory for user
  systemd.tmpfiles.rules = [
    "d /home/${config.mySystem.user.name}/.config 0755 ${config.mySystem.user.name} users -"
    "d /home/${config.mySystem.user.name}/.config/sops 0755 ${config.mySystem.user.name} users -"
    "d /home/${config.mySystem.user.name}/.config/sops/age 0700 ${config.mySystem.user.name} users -"
  ];
}