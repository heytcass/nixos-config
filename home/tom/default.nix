{ config, pkgs, ... }:

{
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "24.11";
    
    # Modern Unix tools
    packages = with pkgs; [
      # Modern Unix tools
      bat          # Better cat
      bottom       # Better top
      fastfetch    # Better neofetch
      fd           # Better find
      ripgrep      # Better grep
      dogdns      # Better dig
      dua         # Better du
      duf         # Better df
      
      # Development tools
      gh           # GitHub CLI
      git         # Version control
      fzf         # Fuzzy finder
    ];
  };

  programs = {
    home-manager.enable = true;
    
    # Shell setup
    fish = {
      enable = true;
      shellAliases = {
        # Modern Unix alternatives
        cat = "bat --paging=never";
        top = "btm";
        htop = "btm";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        tree = "eza --tree";
        find = "fd";
        grep = "rg";
        neofetch = "fastfetch";
        
        # System management
        rebuild = "sudo nixos-rebuild switch --flake .#gti";
        update = "nix flake update";
      };
    };

    # Modern replacements
    bat = {
      enable = true;
      config = {
        theme = "TwoDark";
        style = "numbers,changes,header";
      };
    };

    bottom = {
      enable = true;
      settings = {
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };

    eza = {
      enable = true;
      enableFishIntegration = true;  # Instead of enableAliases
      git = true;
      icons = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
    };

    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = ["--cmd cd"];
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };
      };
    };

    direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
      };
    };

    git = {
      enable = true;
      userName = "Tom Cassady";
      # Add your email here
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        core.editor = "micro";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}