{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.services.claude-mcp;

  # Generate the Claude Desktop configuration

  # Write the configuration file

in
{
  options.services.claude-mcp = {
    enable = mkEnableOption "Claude Desktop MCP server configuration";

    servers = mkOption {
      type = types.attrs;
      default = { };
      description = "MCP server configurations";
      example = literalExpression ''
        {
          "nixos" = {
            command = "nix";
            args = [ "run" "github:utensils/mcp-nixos" "--" ];
          };
          "obsidian" = {
            command = "npx";
            args = [ "-y" "@smithery/cli@latest" "run" "mcp-obsidian" "--config" "{\"vaultPath\":\"/home/tom/Documents/Personal Vault/\"}" ];
          };
        }
      '';
    };

    user = mkOption {
      type = types.str;
      default = "tom";
      description = "User for Claude Desktop configuration";
    };

    vaultPath = mkOption {
      type = types.path;
      default = "/home/tom/Documents/Personal Vault";
      description = "Path to Obsidian vault for MCP integration";
    };
  };

  config = mkIf cfg.enable {
    # Install additional packages needed for MCP servers
    environment.systemPackages = with pkgs; [
      nodejs
      nodePackages.npm
      git
    ];

    # Ensure the .config/Claude directory exists and generate config with secrets
    system.userActivationScripts.claude-mcp = ''
            mkdir -p /home/${cfg.user}/.config/Claude
            mkdir -p /home/${cfg.user}/.local/share

            # Install Google Sheets MCP server if not already present
            if [ ! -d "/home/${cfg.user}/.local/share/google-sheets-mcp" ]; then
              cd /home/${cfg.user}/.local/share
              ${pkgs.git}/bin/git clone https://github.com/mkummer225/google-sheets-mcp.git
              cd google-sheets-mcp

              # Install dependencies and build
              ${pkgs.nodejs}/bin/npm install
              ${pkgs.nodejs}/bin/npm run build

              # Set proper ownership
              chown -R ${cfg.user}:users /home/${cfg.user}/.local/share/google-sheets-mcp
            fi

            # Generate Google OAuth credentials file from SOPS secrets
            if [ -f "/run/secrets/google_oauth_client_id" ] && [ -f "/run/secrets/google_oauth_client_secret" ]; then
              CLIENT_ID=$(cat /run/secrets/google_oauth_client_id)
              CLIENT_SECRET=$(cat /run/secrets/google_oauth_client_secret)

              cat > /home/${cfg.user}/.local/share/google-sheets-mcp/dist/gcp-oauth.keys.json << EOF
      {
        "installed": {
          "client_id": "$CLIENT_ID",
          "project_id": "claude-mcp-integration",
          "auth_uri": "https://accounts.google.com/o/oauth2/auth",
          "token_uri": "https://oauth2.googleapis.com/token",
          "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
          "client_secret": "$CLIENT_SECRET",
          "redirect_uris": ["http://localhost"]
        }
      }
      EOF

              # Set proper ownership
              chown ${cfg.user}:users /home/${cfg.user}/.local/share/google-sheets-mcp/dist/gcp-oauth.keys.json
              chmod 600 /home/tom/.local/share/google-sheets-mcp/dist/gcp-oauth.keys.json
            fi

            # Create wrapper script to redirect console output to stderr
            cat > /home/${cfg.user}/.local/share/google-sheets-mcp/wrapper.js << 'EOF'
      #!/usr/bin/env node

      // Wrapper to redirect console output to stderr for MCP compatibility
      const originalConsoleLog = console.log;
      const originalConsoleError = console.error;

      // Redirect all console output to stderr
      console.log = (...args) => originalConsoleError(...args);
      console.error = (...args) => originalConsoleError(...args);

      // Import and run the original server
      import('./dist/index.js');
      EOF
            chmod +x /home/${cfg.user}/.local/share/google-sheets-mcp/wrapper.js
            chown ${cfg.user}:users /home/${cfg.user}/.local/share/google-sheets-mcp/wrapper.js

            # Generate configuration with secrets substituted
            ${pkgs.writeShellScript "generate-claude-config" ''
                      #!/bin/bash

                      # Read the Home Assistant token from secrets
                      HA_TOKEN=""
                      if [ -f "/run/secrets/home_assistant_token" ]; then
                        HA_TOKEN=$(cat /run/secrets/home_assistant_token)
                      fi

                      # Read Google OAuth credentials from secrets
                      GOOGLE_OAUTH_CLIENT_ID=""
                      GOOGLE_OAUTH_CLIENT_SECRET=""
                      if [ -f "/run/secrets/google_oauth_client_id" ]; then
                        GOOGLE_OAUTH_CLIENT_ID=$(cat /run/secrets/google_oauth_client_id)
                      fi
                      if [ -f "/run/secrets/google_oauth_client_secret" ]; then
                        GOOGLE_OAUTH_CLIENT_SECRET=$(cat /run/secrets/google_oauth_client_secret)
                      fi


                      # Generate the Claude Desktop configuration with secrets
                      cat > /home/${cfg.user}/.config/Claude/claude_desktop_config.json << EOF
              {
                "mcpServers": {
                  "Home Assistant": {
                    "command": "/home/${cfg.user}/.local/bin/mcp-proxy",
                    "env": {
                      "SSE_URL": "https://hass.cassady.house/mcp_server/sse",
                      "API_ACCESS_TOKEN": "$HA_TOKEN"
                    }
                  },
                  "nixos": {
                    "command": "nix",
                    "args": ["run", "github:utensils/mcp-nixos", "--"]
                  },
                  "google-sheets": {
                    "command": "node",
                    "args": ["/home/${cfg.user}/.local/share/google-sheets-mcp/wrapper.js"]
                  }
                },
                "isUsingBuiltInNodeForMcp": false
              }
              EOF

                      # Set proper ownership
                      chown ${cfg.user}:users /home/${cfg.user}/.config/Claude/claude_desktop_config.json
                      chmod 600 /home/${cfg.user}/.config/Claude/claude_desktop_config.json
            ''}
    '';

    # Note: Node.js and npm are provided by development.nix mixin

    # Create a development environment for MCP servers
    environment.shellInit = ''
      # MCP Development Environment
      export MCP_VAULT_PATH="${cfg.vaultPath}"
      export MCP_USER_HOME="/home/${cfg.user}"
    '';
  };
}
