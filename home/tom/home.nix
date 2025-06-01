{
  pkgs,
  config,
  ...
}: {
  # User configuration
  home.username = "tom";
  home.homeDirectory = "/home/tom";
  home.stateVersion = "25.05";


  # User packages
  home.packages = with pkgs; [
    git
    gh
    vscode
    starship      # Cross-shell prompt
    
    # Modern command-line tools
    bat           # Better cat with syntax highlighting
    eza           # Modern ls with colors and icons
    fd            # Modern find replacement
    procs         # Modern ps with better formatting
    bottom        # Enhanced top alternative
    dogdns        # Modern dig replacement
    gping         # Ping with real-time graphs
    bandwhich     # Network usage by process
    mtr           # Better traceroute
    dua           # Visual disk usage analyzer
    rclone        # Cloud storage sync
    yazi          # Terminal file manager
    hyperfine     # Command-line benchmarking
    tldr          # Simplified man pages
    entr          # Run commands when files change
    croc          # Easy file transfer
    magic-wormhole-rs  # Secure file sharing
  ];

  # Dotfiles (currently managed through GUI/sync)
  home.file = {};

  # Services
  services.ssh-agent.enable = true;

  # Environment variables
  home.sessionVariables = {};

  # Hide terminal apps from launcher
  xdg.desktopEntries = {
    bottom = {
      name = "bottom";
      noDisplay = true;
    };
    yazi = {
      name = "yazi";
      noDisplay = true;
    };
  };

  # Program configurations
  programs = {
    home-manager.enable = true;
    
    # Shell aliases for modern tools
    bash = {
      enable = true;
      shellAliases = {
        cat = "bat";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        find = "fd";
        ps = "procs";
        top = "btm";
        dig = "dog";
        ping = "gping";
        du = "dua interactive";
        tree = "eza --tree";
      };
    };
    
    fish = {
      enable = true;
      shellAliases = {
        cat = "bat";
        ls = "eza";
        ll = "eza -l";
        la = "eza -la";
        find = "fd";
        ps = "procs";
        top = "btm";
        dig = "dog";
        ping = "gping";
        du = "dua interactive";
        tree = "eza --tree";
      };
    };
    
    starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      settings = {
        format = "$all$character";
        right_format = "$time";
        
        character = {
          success_symbol = "[➜](bold green)";
          error_symbol = "[➜](bold red)";
        };
        
        directory = {
          truncation_length = 3;
          truncate_to_repo = false;
        };
        
        git_branch = {
          format = "[$symbol$branch]($style) ";
          symbol = " ";
        };
        
        git_status = {
          conflicted = "⚡";
          ahead = "⇡";
          behind = "⇣";
          diverged = "⇕";
          untracked = "?";
          stashed = "$";
          modified = "!";
          staged = "+";
          renamed = "»";
          deleted = "✘";
        };
        
        time = {
          disabled = false;
          format = "[$time]($style)";
          time_format = "%H:%M";
        };
        
        cmd_duration = {
          min_time = 2000;
          format = "[$duration]($style) ";
        };
        
        nix_shell = {
          format = "[nix $name]($style) ";
        };
      };
    };
    
    git = {
      enable = true;
      userName = "Tom Cassady";
      userEmail = "heytcass@gmail.com";
    };
    
    gh = {
      enable = true;
      settings = {
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
    };
  };
}