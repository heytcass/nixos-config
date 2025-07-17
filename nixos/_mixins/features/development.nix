# Development tools and environment mixin
# Provides essential development tools and configurations

{
  pkgs,
  inputs,
  ...
}:

{

  # Essential development packages (always loaded)
  environment.systemPackages = with pkgs; [
    # Claude Desktop with FHS for MCP servers
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs

    # Essential development tools
    git
    curl
    wget
    micro
    
    # Binary cache tools
    cachix
    
    # Container tools (lightweight)
    podman
    
    # Development environment manager
    (writeShellScriptBin "dev-env" (builtins.readFile ../../scripts/dev-env.sh))
    
    # NOTE: Heavy development tools moved to conditional loading:
    # - nodejs/npm: Use project-specific flake.nix or dev-env script
    # - lazydocker: Use on-demand with 'nix run nixpkgs#lazydocker'
    # - yubikey-manager: Use on-demand with 'nix run nixpkgs#yubikey-manager'
    # - rustc: Use 'dev-env rust' for Rust development
  ];

  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable podman socket for container management
  systemd.user.services.podman.wantedBy = [ "default.target" ];

  # Environment variables for container tools
  environment.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };

}
