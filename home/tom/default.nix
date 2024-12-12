{ config, pkgs, ... }:

{
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.fish.enable = true;

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      format = ''
        [](#9A348E)$directory$git_branch$git_status$nix_shell$python$nodejs
        $character'';

      add_newline = true;

      character = {
        success_symbol = "[❯](bold green)";
        error_symbol = "[❯](bold red)";
        vimcmd_symbol = "[❮](bold green)";
      };

      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
        format = "[$path]($style)[$read_only]($read_only_style) ";
      };

      # Enhanced Nix Shell Configuration
      nix_shell = {
        symbol = " ";  # Nix snowflake
        format = "via [$symbol$state( \($name\))]($style) ";
        style = "bold blue";
        pure_msg = "λ";
        impure_msg = "⎔";
        unknown_msg = "?";
        heuristic = true;
      };

      # Direnv status (useful for nix develop)
      env_var = {
        DIRENV_DIR = {
          format = "direnv [$symbol$env_value]($style) ";
          style = "bold yellow";
          symbol = "📦";
        };
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "bold red";
        format = "([\\[$all_status$ahead_behind\\]]($style) )";
        modified = "!";
        untracked = "?";
        staged = "+";
        renamed = "»";
        deleted = "✘";
      };

      # Detect common Nix file extensions
      custom.nix_file = {
        format = "nix [$symbol$output]($style) ";
        symbol = "❄️ ";
        style = "bold blue";
        extensions = ["nix"];
        directory = ["flake.nix", "shell.nix", "default.nix"];
        command = "echo 'file'";
        when = "test -f *.nix";
      };
    };
  };
}