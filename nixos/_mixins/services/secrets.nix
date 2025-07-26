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
  # Import sops-nix module for non-ISO systems only
  imports = if (!isISO) then [ inputs.sops-nix.nixosModules.sops ] else [ ];

  # Only enable secrets configuration for non-ISO systems
  config = lib.mkIf (!isISO) {
    sops = {
      # Default secrets file location
      defaultSopsFile = ../../../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      # Age configuration
      age = {
        # Use the age key stored in system location for better security
        keyFile = "/etc/sops/age/keys.txt";
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

        # Home Assistant token - for MCP server integration
        "home_assistant_token" = {
          owner = "tom";
          group = "users";
          mode = "0400";
          path = "/run/secrets/home_assistant_token";
        };

        # Google OAuth client ID - for Google Sheets MCP server
        "google_oauth_client_id" = {
          owner = "tom";
          group = "users";
          mode = "0400";
          path = "/run/secrets/google_oauth_client_id";
        };

        # Google OAuth client secret - for Google Sheets MCP server
        "google_oauth_client_secret" = {
          owner = "tom";
          group = "users";
          mode = "0400";
          path = "/run/secrets/google_oauth_client_secret";
        };

      };
    };

    # Ensure proper age key permissions on system activation
    system.activationScripts.sops-age-key = {
      text = ''
        if [ -f /etc/sops/age/keys.txt ]; then
          chown root:root /etc/sops/age/keys.txt
          chmod 600 /etc/sops/age/keys.txt
        fi
      '';
      deps = [ "etc" ];
    };
  };
}
