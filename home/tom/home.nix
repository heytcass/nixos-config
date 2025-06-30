{
  pkgs,
  inputs,
  lib,
  isISO ? false,
  ...
}:

let
  # Common shell aliases for modern CLI tools
  commonShellAliases = {
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
    nano = "micro";

    # Rust utility aliases (with fallback to GNU versions)
    # sudo = "sudo-rs";
    # Core utilities (most common first)
    cp = "ucp";
    mv = "umv";
    rm = "urm";
    mkdir = "umkdir";
    rmdir = "urmdir";
    touch = "utouch";
    chmod = "uchmod";
    chown = "uchown";
    # Text processing
    sort = "usort";
    uniq = "uuniq";
    cut = "ucut";
    head = "uhead";
    tail = "utail";
    wc = "uwc";
    # File operations
    stat = "ustat";
    ln = "uln";
    # System info
    whoami = "uwhoami";
    id = "uid";
    groups = "ugroups";
    # Path utilities
    basename = "ubasename";
    dirname = "udirname";
    readlink = "ureadlink";
  };
in

{
  # User configuration
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "25.05";

    # User packages
    packages = with pkgs; [
      # Development tools
      gh
      vscode
      starship # Cross-shell prompt

      # Modern command-line tools
      bat # Better cat with syntax highlighting
      eza # Modern ls with colors and icons
      fd # Modern find replacement
      procs # Modern ps with better formatting
      bottom # Enhanced top alternative
      dogdns # Modern dig replacement
      gping # Ping with real-time graphs
      bandwhich # Network usage by process
      mtr # Better traceroute
      dua # Visual disk usage analyzer
      rclone # Cloud storage sync
      yazi # Terminal file manager
      hyperfine # Command-line benchmarking
      tldr # Simplified man pages
      entr # Run commands when files change
      croc # Easy file transfer
      magic-wormhole-rs # Secure file sharing

      # Desktop applications (moved from system config)
      bitwarden-desktop
      boatswain
      claude-code
      discord
      google-chrome
      slack
      spotify
      todoist-electron
      zoom-us

    ];

    # Dotfiles (currently managed through GUI/sync)
    file = { };

    # GitHub CLI is configured to use encrypted token
    # Authentication can be done manually: gh auth login --with-token < /run/secrets/github_token

    # Environment variables
    sessionVariables = {
      STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };

  # Services
  services.ssh-agent.enable = true;

  # Configure Papirus folder colors to match terracotta theme
  home.activation.configurePapirusFolders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.papirus-folders}/bin/papirus-folders -C orange --theme Papirus || true
  '';

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
    fish = {
      name = "fish";
      noDisplay = true;
    };
    micro = {
      name = "micro";
      noDisplay = true;
    };
  };

  # Set Ghostty as default terminal
  xdg.mimeApps.defaultApplications = {
    "application/x-terminal-emulator" = "ghostty.desktop";
    "x-scheme-handler/terminal" = "ghostty.desktop";
  };

  # Program configurations
  programs = {
    home-manager.enable = true;

    # Shell aliases for modern tools
    bash = {
      enable = true;
      shellAliases =
        commonShellAliases
        // lib.optionalAttrs (!isISO) {
          gh-auth = "gh auth login --with-token < /run/secrets/github_token";
        };
    };

    fish = {
      enable = true;
      shellAliases =
        commonShellAliases
        // lib.optionalAttrs (!isISO) {
          gh-auth = "gh auth login --with-token < /run/secrets/github_token";
        };
      interactiveShellInit = ''
        # Ghostty-specific optimizations
        if test "$TERM_PROGRAM" = "ghostty"
          alias clear='printf "\033[2J\033[3J\033[1;1H"'
          alias reload='source ~/.config/fish/config.fish'
        end
      '';

      # Directory-specific cachix auto-start
      functions = {
        __cachix_nixos_check = {
          body = ''
            # Auto-start cachix watch-store when entering NixOS config directory
            if test "$PWD" = "/home/tom/.nixos"
              if not pgrep -f "cachix watch-store tcass-nixos-config" > /dev/null 2>&1
                # Only start if not in SSH session and not in vscode terminal
                if test -z "$SSH_CLIENT" -a "$TERM_PROGRAM" != "vscode"
                  echo "🚀 Starting cachix watch-store for NixOS development..."
                  echo "   Logs: /tmp/cachix-watch.log"
                  nohup cachix watch-store tcass-nixos-config > /tmp/cachix-watch.log 2>&1 &
                  disown
                  sleep 1
                  if pgrep -f "cachix watch-store tcass-nixos-config" > /dev/null 2>&1
                    echo "✅ Cachix watch-store started successfully"
                  else
                    echo "❌ Failed to start cachix watch-store"
                  end
                else
                  if test -n "$SSH_CLIENT"
                    echo "📡 SSH session detected - skipping cachix auto-start"
                  else if test "$TERM_PROGRAM" = "vscode"
                    echo "💻 VSCode terminal detected - skipping cachix auto-start"
                  end
                end
              else
                echo "✅ Cachix watch-store already running"
              end
            end
          '';
          onVariable = "PWD";
        };
      };
    };

    starship = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
      settings = {
        format = ''$username$hostname$directory$git_branch$git_status$nix_shell$package$nodejs$python$rust$golang$docker_context$kubernetes$cmd_duration$line_break$character'';
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
      extraConfig = {
        credential.helper = "store";
      };
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
      extraConfig = ''
        # Use encrypted SSH key from secrets (when available)
        ${lib.optionalString (!isISO) "IdentityFile /run/secrets/ssh_private_key"}
        IdentityFile ~/.ssh/id_ed25519
      '';
    };

    # Ghostty terminal configuration
    ghostty = {
      enable = true;
      enableFishIntegration = true;
      package = inputs.ghostty.packages.${pkgs.system}.default;
      settings = {
        # Font configuration using existing Nerd Fonts
        font-family = "Hack Nerd Font";
        font-size = 12;

        # Theme
        theme = "claude-terracotta";

        # Keybindings
        keybind = [
          "ctrl+shift+c=copy_to_clipboard"
          "ctrl+shift+v=paste_from_clipboard"
          "ctrl+shift+t=new_tab"
          "ctrl+shift+w=close_surface"
          "ctrl+shift+n=new_window"
          "shift+enter=text:\n"
        ];

        # Window settings
        window-padding-x = 8;
        window-padding-y = 8;

        # Shell integration
        shell-integration = "fish";

        # Performance
        copy-on-select = true;

        # Mouse
        mouse-hide-while-typing = true;

        # Clipboard
        clipboard-read = "allow";
        clipboard-write = "allow";
      };

      # Custom theme based on Claude Theme VSCode color scheme
      themes.claude-terracotta = {
        background = "1a1915";
        foreground = "c3c0b6";
        cursor-color = "d97757";
        cursor-text = "1a1915";
        selection-background = "3e3e38";
        selection-foreground = "faf9f5";

        # ANSI colors (0-7)
        palette = [
          "0=1a1915" # black
          "1=e77e7c" # red
          "2=a3c778" # green
          "3=e7c470" # yellow
          "4=7aafca" # blue
          "5=c278af" # magenta
          "6=78c0af" # cyan
          "7=c3c0b6" # white
          "8=525152" # bright black
          "9=f08a87" # bright red
          "10=b1d383" # bright green
          "11=f0d283" # bright yellow
          "12=83bfd3" # bright blue
          "13=d383bf" # bright magenta
          "14=83d3bf" # bright cyan
          "15=faf9f5" # bright white
        ];
      };
    };
  };
}
