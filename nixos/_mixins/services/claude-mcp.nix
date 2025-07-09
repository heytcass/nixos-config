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
    # Ensure the .config/Claude directory exists and generate config with secrets
    system.userActivationScripts.claude-mcp = ''
      mkdir -p /home/${cfg.user}/.config/Claude

      # Generate configuration with secrets substituted
      ${pkgs.writeShellScript "generate-claude-config" ''
                #!/bin/bash

                # Read the Home Assistant token from secrets
                HA_TOKEN=""
                if [ -f "/run/secrets/home_assistant_token" ]; then
                  HA_TOKEN=$(cat /run/secrets/home_assistant_token)
                fi

                # Read the Obsidian API key from secrets
                OBSIDIAN_API_KEY=""
                if [ -f "/run/secrets/obsidian_api_key" ]; then
                  OBSIDIAN_API_KEY=$(cat /run/secrets/obsidian_api_key)
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

    # Install required packages
    environment.systemPackages = with pkgs; [
      nodejs
      nodePackages.npm
    ];

    # Create a development environment for MCP servers
    environment.shellInit = ''
      # MCP Development Environment
      export MCP_VAULT_PATH="${cfg.vaultPath}"
      export MCP_USER_HOME="/home/${cfg.user}"
    '';
  };
}
