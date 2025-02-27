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
      # Font settings
      "font-family" = "FiraCode Nerd Font";
      "font-size" = 12;
      "font-feature" = [
        "liga"
        "calt"
        "ss01"
        "ss02"
        "ss03"
        "ss04"
        "ss05"
      ];

      # Window settings
      "window-padding-x" = 10;
      "window-padding-y" = 10;
      "window-theme" = "dark";
      "window-save-state" = true;
      "cursor-style" = "block";
      "cursor-style-blink" = true;

      # Adwaita Dark theme
      "background" = "#1d1d1d";
      "foreground" = "#c0bfbc";
      "selection-background" = "#3584e4";
      "selection-foreground" = "#ffffff";
      "cursor-color" = "#c0bfbc";

      # Normal colors (Adwaita-like)
      "palette = 0" = "#1d1d1d";
      "palette = 1" = "#ed333b";
      "palette = 2" = "#57e389";
      "palette = 3" = "#f8e45c";
      "palette = 4" = "#3584e4";
      "palette = 5" = "#c061cb";
      "palette = 6" = "#5bc8af";
      "palette = 7" = "#c0bfbc";

      # Bright colors (Adwaita-like)
      "palette = 8" = "#8f8f8f";
      "palette = 9" = "#f66151";
      "palette = 10" = "#8ff0a4";
      "palette = 11" = "#f9f06b";
      "palette = 12" = "#62a0ea";
      "palette = 13" = "#dc8add";
      "palette = 14" = "#93ddc2";
      "palette = 15" = "#f6f5f4";

      # UI preferences
      "confirm-close-surface" = false;
      "mouse-hide-while-typing" = true;
      "scrollback-lines" = 10000;
      "shell-integration-features" = "no-cursor";
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
