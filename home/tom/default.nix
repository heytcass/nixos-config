{ config, pkgs, ... }:

{
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.fish = {
    enable = true;
    
    # Add aliases
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake .#gti";
      needsreboot = "nixos-needsreboot";
    };
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      add_newline = true;

      # Enhanced Nix Shell Configuration
      nix_shell = {
        symbol = "❄️ ";
        format = "via [$symbol($state)\($name\)]($style) ";
        style = "bold blue";
        pure_msg = "pure";
        impure_msg = "impure";
        unknown_msg = "unknown";
        heuristic = true;
      };

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };

      # Enhanced Git configuration
      git_branch = {
        symbol = "🌱 ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([$all_status$ahead_behind]($style) )";
        ahead = "⇡";
        behind = "⇣";
        diverged = "⇕";
        conflicted = "=";
        deleted = "✖";
        modified = "!";
        renamed = "»";
        staged = "+";
        stashed = "\\$";
        untracked = "?";
      };
    };
  };
}