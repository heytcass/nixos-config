{ config, pkgs, lib, sops-nix, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
in
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
      # "wifi/home_password" = shared.secrets.system // { mode = "0440"; };
      # "services/github_token" = shared.secrets.development;
      # "services/openai_api_key" = shared.secrets.development;
      # "services/anthropic_api_key" = shared.secrets.development;
    };
  };

  # Create initial age key directory for user
  systemd.tmpfiles.rules = [
    "d /home/${shared.user.name}/.config 0755 ${shared.user.name} users -"
    "d /home/${shared.user.name}/.config/sops 0755 ${shared.user.name} users -"
    "d /home/${shared.user.name}/.config/sops/age 0700 ${shared.user.name} users -"
  ];
}