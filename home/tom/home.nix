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
        format = ''
          $username$hostname$directory$git_branch$git_status$nix_shell$package$nodejs$python$rust$golang$docker_context$kubernetes$cmd_duration$line_break$character'';
        right_format = "$time$battery";
        
        character = {
          success_symbol = "[❯](bold green)";
          error_symbol = "[❯](bold red)";
          vimcmd_symbol = "[❮](bold green)";
        };
        
        username = {
          show_always = false;
          style_user = "bold blue";
          style_root = "bold red";
          format = "[$user]($style) ";
        };
        
        hostname = {
          ssh_only = true;
          format = "[@$hostname]($style) ";
          style = "bold cyan";
        };
        
        directory = {
          style = "bold cyan";
          format = "[$path]($style)[$read_only]($read_only_style) ";
          truncation_length = 3;
          truncate_to_repo = false;
          read_only = " 󰌾";
        };
        
        git_branch = {
          symbol = " ";
          format = "[$symbol$branch]($style) ";
          style = "bold purple";
        };
        
        git_status = {
          style = "bold yellow";
          format = ''([\[$all_status$ahead_behind\]]($style) )'';
          ahead = "⇡$count";
          behind = "⇣$count";
          diverged = "⇕⇡$ahead_count⇣$behind_count";
          conflicted = " $count";
          deleted = " $count";
          renamed = " $count";
          modified = " $count";
          staged = " $count";
          untracked = " $count";
          stashed = " $count";
        };
        
        cmd_duration = {
          min_time = 2000;
          format = "[ $duration]($style) ";
          style = "bold yellow";
        };
        
        time = {
          disabled = false;
          format = "[ $time]($style)";
          style = "bold white";
          time_format = "%H:%M";
        };
        
        battery = {
          full_symbol = " ";
          charging_symbol = " ";
          discharging_symbol = " ";
          unknown_symbol = " ";
          empty_symbol = " ";
          display = [
            {
              threshold = 10;
              style = "bold red";
            }
            {
              threshold = 30;
              style = "bold yellow";
            }
          ];
        };
        
        nix_shell = {
          symbol = " ";
          format = "[$symbol$name]($style) ";
          style = "bold blue";
        };
        
        package = {
          symbol = "󰏗 ";
          format = "[$symbol$version]($style) ";
          style = "bold green";
        };
        
        nodejs = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold green";
        };
        
        python = {
          symbol = " ";
          format = "[\${symbol}\${pyenv_prefix}(\$version )(\$virtualenv )](\$style)";
          style = "bold yellow";
        };
        
        rust = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold orange";
        };
        
        golang = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold cyan";
        };
        
        docker_context = {
          symbol = " ";
          format = "[$symbol$context]($style) ";
          style = "bold blue";
        };
        
        kubernetes = {
          symbol = "☸ ";
          format = "[$symbol$context( ($namespace))]($style) ";
          style = "bold cyan";
          disabled = false;
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