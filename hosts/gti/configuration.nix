# Dell XPS 13 9370 - Main workstation configuration
# Host-specific settings for the gti system

{
  hostname,
  ...
}:
{
  imports = [
    # Hardware configuration (auto-generated)
    ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = hostname;

  # Host-specific overrides can go here
  # Most configuration is now handled by the mixin system

  # Claude MCP server configuration
  services.claude-mcp = {
    enable = true;
    user = "tom";
    vaultPath = "/home/tom/Documents/Personal Vault";
  };
}
