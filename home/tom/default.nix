{ config, pkgs, ... }:

{
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  # Fish shell configuration
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # Remove fish default greeting
      set fish_greeting
    '';

    plugins = [
      # Plugin example format, we'll add these based on your preferences
      # {
      #   name = "plugin-name";
      #   src = pkgs.fetchFromGitHub {
      #     owner = "owner";
      #     repo = "repo";
      #     rev = "revision";
      #     sha256 = "sha256";
      #   };
      # }
    ];
  };

  # Starship prompt configuration
  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    # We can customize the prompt later if you want
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
      };
    };
  };
}