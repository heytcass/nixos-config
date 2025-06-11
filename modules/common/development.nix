{
  config,
  pkgs,
  inputs,
  lib,
  ...
}: {
  # Development programs
  programs.fish.enable = true;

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
  ];

  # Git configuration (system-wide)
  programs.git = {
    enable = true;
    config = {
      credential.helper = "store";
    };
  };
}