# Development tools and environment mixin
# Provides essential development tools and configurations

{
  pkgs,
  inputs,
  ...
}:

{

  # Development packages
  environment.systemPackages = with pkgs; [
    # Claude Desktop with FHS for MCP servers
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs

    # Development tools
    git
    curl
    wget
    micro
    yubikey-manager

    # Binary cache tools
    cachix
  ];

}
