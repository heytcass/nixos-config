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

    # Node.js development environment
    nodejs
    nodePackages.npm

    # Binary cache tools
    cachix

    # Container tools
    podman
    lazydocker
  ];

  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable podman socket for lazydocker compatibility
  systemd.user.services.podman.wantedBy = [ "default.target" ];

  # Environment variables for lazydocker/podman compatibility
  environment.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };

}
