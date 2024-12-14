{ config, pkgs, lib, ... }:

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
      croc        # File transfer
      httpie      # Modern curl
      
      # Development tools
      gh           # GitHub CLI
      git         # Version control
      fzf         # Fuzzy finder
      
      # File management
      ueberzugpp  # Terminal image previews
      chafa       # Terminal image viewer
      unzip       # Zip files
      p7zip       # 7z files
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
        
        # File management
        fm = "yazi";  # Quick file manager access
        http = "httpie";
        send = "croc send";
        receive = "croc";
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
      enableFishIntegration = true;
      git = true;
      icons = "auto";
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

    yazi = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        manager = {
          show_hidden = false;
          show_symlink = true;
          sort_by = "natural";
          sort_dir_first = true;
          sort_sensitive = false;
          sort_reverse = false;
        };
      };
    };

    # Shell and CLI enhancements
    fzf = {
      enable = true;
      enableFishIntegration = true;
      defaultCommand = "fd --type f --hidden --exclude .git";
      defaultOptions = ["--height 50% --border"];
    };

    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = ["--disable-up-arrow"];
      settings = {
        auto_sync = true;
        dialect = "us";
        show_preview = true;
        style = "compact";
        sync_frequency = "1h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
      };
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        format = lib.concatStrings [
          "$directory"
          "$git_branch"
          "$git_status"
          "$character"
        ];
        
        directory = {
          style = "bold cyan";
          truncate_to_repo = true;
          truncation_length = 3;
          format = "[$path]($style)[$read_only]($read_only_style) ";
        };

        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
        };

        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = "🌱 ";
          style = "bold purple";
        };

        git_status = {
          format = "([🏗️ $all_status$ahead_behind]($style) )";
          style = "bold red";
          conflicted = "󰳤 ";
          ahead = "⇡";
          behind = "⇣";
          diverged = "⇕";
          untracked = " ";
          stashed = "󰆓 ";
          modified = " ";
          staged = "📦 ";
          deleted = "󰗨 ";
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
      userEmail = "heytcass@gmail.com";
      aliases = {
        ci = "commit";
        cl = "clone";
        co = "checkout";
        purr = "pull --rebase";
        dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
        dshow = "!f() { GIT_EXTERNAL_DIFF=difft git show --ext-diff $@; }; f";
        fucked = "reset --hard";
        graph = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      difftastic = {
        enable = true;
        display = "side-by-side-show-both";
      };
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        core = {
          editor = "micro";
          pager = "bat";
        };
        push.default = "matching";
        color = {
          ui = "auto";
          branch = true;
          diff = true;
          interactive = true;
          status = true;
        };
      };
    };

    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        editor = "micro";
        prompt = "enabled";
      };
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}