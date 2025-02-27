{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "tom";
  home.homeDirectory = "/home/tom";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # User packages that were in your configuration.nix
  home.packages = with pkgs; [
    google-chrome
    bitwarden-desktop
    nodejs
    gh
    ripgrep
    node2nix
    # Terminal
    ghostty
    # Add any other user packages you want here
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Tom Cassady";
    userEmail = "heytcass@gmail.com";
    # Additional git configuration can go here
  };

  # Terminal configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      nixos-rebuild-flake = "sudo nixos-rebuild switch --flake ~/.nixos-config#gti";
      claude-code = "npx @anthropic-ai/claude-code";
    };
  };
  
  # Set Ghostty as default terminal
  home.sessionVariables = {
    TERMINAL = "ghostty";
  };

  # Ghostty terminal configuration
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "FiraCode Nerd Font";
      font-size = 12;
      
      # Additional settings you might want
      confirm-close = false;
      window-padding-x = 10;
      window-padding-y = 10;
      
      # Theme settings
      background = "#282c34";
      foreground = "#abb2bf";
    };
  };

  # VSCode if you use it
  # programs.vscode = {
  #   enable = true;
  #   extensions = with pkgs.vscode-extensions; [
  #     # Add extensions you want
  #   ];
  # };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.11";
}
