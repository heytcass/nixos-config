# Secrets management with sops-nix
# Provides encrypted secrets handling using age encryption

{ config, lib, inputs, isISO, ... }:

{
  # Import sops-nix module for non-ISO systems
  imports = lib.optionals (!isISO) [ inputs.sops-nix.nixosModules.sops ];
  
  # Only enable secrets configuration for non-ISO systems
  config = lib.mkIf (!isISO) {
    sops = {
      # Default secrets file location  
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";
      
      # Age configuration
      age = {
        # Use the age key we generated
        keyFile = "/home/tom/.config/sops/age/keys.txt";
        generateKey = false; # We already generated it manually
      };
      
      # Example secrets (uncomment and customize as needed)
      secrets = {
        # User password hash (enabled as example)
        "user_password_hash" = {
          neededForUsers = true;
        };
        
        # SSH host keys (enabled as example)
        "ssh_host_ed25519_key" = {
          owner = "root";
          group = "root";
          mode = "0400";
          path = "/etc/ssh/ssh_host_ed25519_key";
        };
        
        # API tokens and keys
        # "api_token" = {
        #   owner = "tom";
        #   group = "users";
        #   mode = "0400";
        # };
        
        # Database passwords
        # "database_password" = {
        #   owner = "postgres";
        #   group = "postgres";
        #   mode = "0400";
        # };
        
        # Network credentials
        # "wireguard_private_key" = {
        #   owner = "systemd-network";
        #   group = "systemd-network";
        #   mode = "0400";
        # };
      };
    };
  };
}