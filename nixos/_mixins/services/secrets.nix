# Traditional SOPS secrets management
# Provides encrypted secrets handling using age encryption

{
  config,
  lib,
  inputs,
  isISO,
  ...
}:

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

      # Define secrets - these will be available at /run/secrets/<name>
      secrets = {
        # WiFi password - accessible at /run/secrets/wifi_password
        "wifi_password" = {
          owner = "tom";
          group = "users";
          mode = "0400";
        };

        # GitHub token - accessible at /run/secrets/github_token
        "github_token" = {
          owner = "tom";
          group = "users";
          mode = "0440"; # Allow group read access
          path = "/run/secrets/github_token";
        };

        # SSH private key - accessible at /run/secrets/ssh_private_key
        "ssh_private_key" = {
          owner = "tom";
          group = "users";
          mode = "0400";
          path = "/run/secrets/ssh_private_key";
        };

        # User password hash - for system authentication
        "user_password_hash" = {
          neededForUsers = true;
        };
      };
    };
  };
}
