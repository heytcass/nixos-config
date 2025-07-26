{
  pkgs,
  inputs,
  lib,
  desktop ? "gnome",
  isISO ? false,
  ...
}:

let
  # Desktop environment helper variables
  isHyprland = desktop == "hyprland";
  isNiri = desktop == "niri";
  isWayland = isHyprland || isNiri;

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
    cn = "cd ~/.nixos";
    nrs = "sudo nixos-rebuild switch --flake .#$(hostname)";

    # Development environment shortcuts
    dev-rust = "dev-env rust";
    dev-web = "dev-env web";
    dev-python = "dev-env python";

    # On-demand development tools
    lazydocker = "nix run nixpkgs#lazydocker";
    yubikey-manager = "nix run nixpkgs#yubikey-manager";
    nodejs = "nix run nixpkgs#nodejs";
    rustc = "nix run nixpkgs#rustc";
    python = "nix run nixpkgs#python3";
    tree = "eza --tree";
    nano = "micro";

    # Rust utility aliases (generated programmatically)
    # sudo = "sudo-rs";  # Disabled until system rebuild completes
  } // (lib.genAttrs [
    # Core utilities
    "cp" "mv" "rm" "mkdir" "rmdir" "touch" "chmod" "chown"
    # Text processing
    "sort" "uniq" "cut" "head" "tail" "wc"
    # File operations  
    "stat" "ln"
    # System info
    "whoami" "id" "groups"
    # Path utilities
    "basename" "dirname" "readlink"
  ] (cmd: "uutils-${cmd}")) // {

    # Enhanced Git workflow
    gl = "git log --oneline --graph --decorate --all";
    gs = "git status -sb";
    gd = "git diff";
    gdc = "git diff --cached";
    gap = "git add -p";
    gcm = "git commit -m";
    gca = "git commit --amend";
    gco = "git checkout";
    gcb = "git checkout -b";
    gp = "git push";
    gpu = "git push -u origin HEAD";
    gpl = "git pull";
    gr = "git rebase";
    gri = "git rebase -i";

    # Modern Git tools
    lg = "lazygit";

    # Project and session management
    z = "zoxide"; # Smart cd replacement (if cd override doesn't work)

    # Code statistics and analysis
    todos = "rg 'TODO|FIXME|HACK|BUG' --type-not sql";

    # Quick file operations with modern tools
    preview = "fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'";
  };
in

{
  imports = lib.optionals isHyprland [ inputs.hyprland.homeManagerModules.default ];

  # User configuration
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "25.05";

    # User packages
    packages = with pkgs; [
      # Development tools
      gh
      # vscode moved to productivity.nix profile
      starship # Cross-shell prompt

      # Material You color generation

      # Icon theming
      papirus-folders # Tool to change Papirus folder colors

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

      # Heavy desktop applications moved to system profiles for better organization
      # (communication.nix, media.nix, productivity.nix)
      boatswain

      # Notifications
      libnotify # For notify-send command
      todoist-electron

      # Bluetooth management tools
      overskride # Modern GTK4 Bluetooth manager - preferred over bluetui

      # System logout/shutdown menu
      wlogout # Wayland logout menu

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
    }
    // lib.optionalAttrs isHyprland {
      # Force dark theme for applications
      GTK_THEME = "Adwaita:dark";
      QT_STYLE_OVERRIDE = lib.mkForce "adwaita-dark";

      # Cursor theme managed by Stylix

      # Claude-themed terminal colors for applications that support it
      CLAUDE_BRAND_COLOR = "#d77757";
      CLAUDE_DARK_BG = "#1f1e1d";
      CLAUDE_LIGHT_FG = "#faf9f5";
    };
  };

  # Services
  services.ssh-agent.enable = true;

  # Automatic display configuration based on connected monitors
  # Enhanced with comprehensive port coverage to handle post-hibernation renumbering
  services.kanshi = {
    enable = true;
    settings = [
      # Three-screen docked profiles (covers all possible DP port combinations)
      # DP-3/DP-4 combination
      {
        profile.name = "docked-3-4";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "1920,0";
          }
          {
            criteria = "DP-3";
            position = "0,0";
          }
          {
            criteria = "DP-4";
            position = "3840,-750";
            transform = "270";
          }
        ];
      }
      # DP-5/DP-6 combination (common after hibernation)
      {
        profile.name = "docked-5-6";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "1920,0";
          }
          {
            criteria = "DP-5";
            position = "0,0";
          }
          {
            criteria = "DP-6";
            position = "3840,-750";
            transform = "270";
          }
        ];
      }
      # DP-1/DP-2 combination
      {
        profile.name = "docked-1-2";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "1920,0";
          }
          {
            criteria = "DP-1";
            position = "0,0";
          }
          {
            criteria = "DP-2";
            position = "3840,-750";
            transform = "270";
          }
        ];
      }
      # DP-7/DP-8 combination
      {
        profile.name = "docked-7-8";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "1920,0";
          }
          {
            criteria = "DP-7";
            position = "0,0";
          }
          {
            criteria = "DP-8";
            position = "3840,-750";
            transform = "270";
          }
        ];
      }
      # Two-screen setup (secondary desk) - also with multiple port options
      {
        profile.name = "secondary-desk-2";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
          {
            criteria = "DP-2";
            position = "1920,-325";
          }
        ];
      }
      {
        profile.name = "secondary-desk-1";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
          {
            criteria = "DP-1";
            position = "1920,-325";
          }
        ];
      }
      # Laptop only (undocked)
      {
        profile.name = "laptop-only";
        profile.outputs = [
          {
            criteria = "eDP-1";
            position = "0,0";
          }
        ];
      }
    ];
  };

  # Automatic circadian rhythm screen temperature control
  services.gammastep = {
    enable = true;
    provider = "manual";
    latitude = 42.69121049601569;
    longitude = -83.15813907911111;
    temperature = {
      day = 6500; # Cool daylight temperature
      night = 3000; # Warm evening temperature
    };
    settings = {
      general = {
        adjustment-method = "wayland";
        gamma = 0.8;
      };
    };
  };

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

        # Quick project switching with fzf
        proj = {
          body = ''
            set -l project_dir (find ~/git ~/projects ~/.nixos -maxdepth 2 -name ".git" -type d 2>/dev/null | \
              sed 's/\/.git$//' | fzf --prompt="Project: " --header="Select project to open")

            if test -n "$project_dir"
              cd "$project_dir"

              # Auto-activate development environment if available
              if test -f flake.nix
                echo "🚀 Nix flake detected - run 'nix develop' to enter dev shell"
              else if test -f Cargo.toml
                echo "🦀 Rust project detected - run 'dev-env rust' for development environment"
              else if test -f package.json
                echo "🌐 Web project detected - run 'dev-env web' for development environment"
              else if test -f pyproject.toml -o -f requirements.txt
                echo "🐍 Python project detected - run 'dev-env python' for development environment"
              end
            end
          '';
        };

        # Quick file editing with fzf
        edit = {
          body = ''
            set -l file (fzf --prompt="Edit: " --preview="bat --color=always --style=numbers --line-range=:500 {}")
            if test -n "$file"
              micro "$file"
            end
          '';
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

        # Claude theme colors
        character = {
          success_symbol = "[❯](bold #d77757)"; # Claude terracotta
          error_symbol = "[❯](bold #ab2b3f)"; # Claude error red
          vimcmd_symbol = "[❮](bold #d77757)"; # Claude terracotta
        };

        username = {
          show_always = false;
          style_user = "bold #d77757"; # Claude terracotta
          style_root = "bold #ab2b3f"; # Claude error red
          format = "[$user]($style) ";
        };

        hostname = {
          ssh_only = true;
          format = "[@$hostname]($style) ";
          style = "bold #7fc8ff"; # Claude blue
        };

        directory = {
          style = "bold #7fc8ff"; # Claude blue
          format = "[$path]($style)[$read_only]($read_only_style) ";
          truncation_length = 3;
          truncate_to_repo = false;
          read_only = " 󰌾";
          read_only_style = "bold #966c1e"; # Claude warning amber
        };

        git_branch = {
          symbol = " ";
          format = "[$symbol$branch]($style) ";
          style = "bold #d77757"; # Claude terracotta
        };

        git_status = {
          style = "bold #966c1e"; # Claude warning amber
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
          style = "bold #966c1e"; # Claude warning amber
        };

        time = {
          disabled = false;
          format = "[ $time]($style)";
          style = "bold #f4f1ec"; # Claude light text
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
              style = "bold #ab2b3f"; # Claude error red
            }
            {
              threshold = 30;
              style = "bold #966c1e"; # Claude warning amber
            }
          ];
        };

        nix_shell = {
          symbol = " ";
          format = "[$symbol$name]($style) ";
          style = "bold #7fc8ff"; # Claude blue
        };

        package = {
          symbol = "󰏗 ";
          format = "[$symbol$version]($style) ";
          style = "bold #2c7a39"; # Claude success green
        };

        nodejs = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold #2c7a39"; # Claude success green
        };

        python = {
          symbol = " ";
          format = "[\${symbol}\${pyenv_prefix}(\$version )(\$virtualenv )](\$style)";
          style = "bold #966c1e"; # Claude warning amber
        };

        rust = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold #d77757"; # Claude terracotta
        };

        golang = {
          symbol = " ";
          format = "[$symbol($version )]($style)";
          style = "bold #7fc8ff"; # Claude blue
        };

        docker_context = {
          symbol = " ";
          format = "[$symbol$context]($style) ";
          style = "bold #7fc8ff"; # Claude blue
        };

        kubernetes = {
          symbol = "☸ ";
          format = "[$symbol$context( ($namespace))]($style) ";
          style = "bold #7fc8ff"; # Claude blue
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

        # Enhanced Git configuration with modern tools
        core.pager = "delta";
        interactive.diffFilter = "delta --color-only";
        delta = {
          navigate = true;
          light = false;
          side-by-side = true;
          line-numbers = true;
          syntax-theme = "base16";
        };
        merge.conflictstyle = "diff3";
        diff.colorMoved = "default";

        # Better Git aliases
        alias = {
          st = "status -sb";
          co = "checkout";
          br = "branch";
          last = "log -1 HEAD";
          visual = "!gitk";
          lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
          unstage = "reset HEAD --";
          staged = "diff --cached";
          unstaged = "diff";
          track = "branch -u origin/$(git branch --show-current)";
        };
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

  # Hyprland-specific configuration
  wayland = lib.optionalAttrs (desktop == "hyprland") {
    windowManager.hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;

      settings = {
        # Monitor configuration for multiple dock setups
        monitor = [
          # Laptop screen (eDP-1) - center for three-screen setup, adjust with hyprctl for two-screen
          "eDP-1,1920x1080@60,1920x0,1"
          # Primary desk Dell monitor (DP-2) - right side, 325px higher, workspace 1
          "DP-2,1920x1080@60,1920x-325,1"
          # Secondary desk - Left Dell monitor (DP-3) - left side, workspace 1
          "DP-3,1920x1080@60,0x0,1"
          # Secondary desk - Right Dell monitor (DP-4) - rotated 90° right, workspace 3
          "DP-4,1920x1080@60,3840x0,1,transform,3"
        ];

        # Input configuration - maintain Colemak layout
        input = {
          kb_layout = "us";
          kb_variant = "colemak";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            clickfinger_behavior = true;
          };
          sensitivity = 0;
        };

        # General settings with Claude theme
        general = {
          # Claude's signature terracotta for borders and accents
          "col.active_border" = lib.mkForce "rgb(d97757) rgb(c96442) 45deg";
          "col.inactive_border" = lib.mkForce "rgb(30302e)";

          # Dark theme with Claude's refined spacing
          border_size = 2;
          gaps_in = 8;
          gaps_out = 16;
          layout = "dwindle";
          allow_tearing = false;

          # Use Claude's warm terracotta for resize borders
          resize_on_border = true;
        };

        # Decoration with Claude aesthetics
        decoration = {
          # Subtle rounding matching Claude's modern design
          rounding = 8;

          # Shadows disabled to prevent waybar interference
          shadow = {
            enabled = false;
          };

          # Blur settings with Claude's refined aesthetic
          blur = {
            enabled = true;
            size = 6;
            passes = 2;
            vibrancy = 0.1696;
          };
        };

        # Animations with Claude's polished UX
        animations = {
          enabled = true;

          # Smooth animations reflecting Claude's polished UX
          bezier = [ "claudeEase, 0.25, 0.1, 0.25, 1.0" ];

          animation = [
            "windows, 1, 6, claudeEase"
            "windowsOut, 1, 6, claudeEase, popin 80%"
            "border, 1, 8, claudeEase"
            "borderangle, 1, 8, claudeEase"
            "fade, 1, 6, claudeEase"
            "workspaces, 1, 6, claudeEase"
          ];
        };

        # Layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        # Trackpad gestures for workspace switching
        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 3;
          workspace_swipe_distance = 300;
          workspace_swipe_cancel_ratio = 0.15;
          workspace_swipe_min_speed_to_force = 30;
          workspace_swipe_direction_lock = true;
          workspace_swipe_direction_lock_threshold = 10;
          workspace_swipe_create_new = true;
        };

        # Misc settings
        misc = {
          disable_hyprland_logo = true; # Disable default wallpaper flash
          disable_splash_rendering = true; # Disable splash screen
        };

        # Workspace rules with Claude's semantic color system and monitor assignments
        workspace = [
          "1, border_color:rgb(2c7a39), monitor:DP-3, gapsin:4, gapsout:8" # Success workspace (development/terminal) - Left Dell monitor
          "2, border_color:rgb(d97757), monitor:eDP-1" # Claude brand workspace (main work) - Laptop screen
          "3, border_color:rgb(966c1e), monitor:DP-4" # Warning workspace (monitoring/logs) - Right Dell monitor (rotated)
          "4, border_color:rgb(ab2b3f)" # Error workspace (debugging)
          "5, border_color:rgb(5769f7)" # Permission workspace (admin tasks)
          "6, border_color:rgb(006666)" # Plan mode workspace (planning/design)
        ];

        # Cursor configuration managed by Stylix

        # Window rules with Claude theme colors for installed packages
        windowrulev2 = [
          "float, class:^(pavucontrol)$"
          "float, class:^(nautilus)$"
          "size 800 600, class:^(nautilus)$"
          "bordercolor rgb(d77757), class:^(ghostty)$"
          "bordercolor rgb(c2c0b6), class:^(nautilus)$"
          "bordercolor rgb(c96442), class:^(mpv)$"
          "bordercolor rgb(c96442), class:^(imv)$"

          # Gaming optimizations
          "fullscreen, class:^(steam_app_.*)$"
          "workspace 8, class:^(steam)$"
          "workspace 8, class:^(steam_app_.*)$"
          "immediate, class:^(steam_app_.*)$" # Disable animations for games
          "noborder, class:^(steam_app_.*)$"
          "suppressevent maximize, class:^(steam_app_.*)$"

          # Video conferencing optimizations
          "float, class:^(zoom)$"
          "center, class:^(zoom)$"
          "size 1200 800, class:^(zoom)$"

          # Claude Desktop specific
          "bordercolor rgb(d77757), class:^(claude-desktop)$"
          "workspace 2, class:^(claude-desktop)$"

          # Screen sharing applications
          "float, title:^(.*screen share.*)$"
          "pin, title:^(.*screen share.*)$"
          "noborder, title:^(.*screen share.*)$"
        ];

        # Keybindings - using Super (Windows/Cmd) key
        "$mod" = "SUPER";

        # Application launchers with Claude theme awareness
        bind = [
          "$mod, Return, exec, ghostty"
          "$mod, space, exec, wofi --show drun"
          "$mod, E, exec, nautilus"

          # Search key for quick launcher access
          ", XF86Search, exec, wofi --show drun"

          # Window management
          "$mod, Q, killactive"
          "$mod, M, exit"
          "$mod, V, togglefloating"
          "$mod, P, pseudo"
          "$mod, J, togglesplit"
          "$mod, F, fullscreen, 0"

          # Move focus
          "$mod, left, movefocus, l"
          "$mod, right, movefocus, r"
          "$mod, up, movefocus, u"
          "$mod, down, movefocus, d"

          # Move windows
          "$mod SHIFT, left, movewindow, l"
          "$mod SHIFT, right, movewindow, r"
          "$mod SHIFT, up, movewindow, u"
          "$mod SHIFT, down, movewindow, d"

          # Workspaces with Claude's semantic meaning
          "$mod, 1, workspace, 1" # Development/Terminal (Success Green)
          "$mod, 2, workspace, 2" # Main Work (Claude Brand)
          "$mod, 3, workspace, 3" # Monitoring (Warning Amber)
          "$mod, 4, workspace, 4" # Debugging (Error Red)
          "$mod, 5, workspace, 5" # Admin (Permission Blue)
          "$mod, 6, workspace, 6" # Planning (Plan Mode Teal)
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspace
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Screenshot - save to Pictures/Screenshots/
          ", Print, exec, mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png"
          "$mod, Print, exec, mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png"

          # Screenshot to clipboard (Shift variants)
          "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mod SHIFT, Print, exec, grim - | wl-copy"

          # Media keys with avizo OSD via dedicated scripts
          ", XF86AudioRaiseVolume, exec, ~/.config/scripts/volume-up.sh"
          ", XF86AudioLowerVolume, exec, ~/.config/scripts/volume-down.sh"
          ", XF86AudioMute, exec, ~/.config/scripts/volume-mute.sh"
          ", XF86MonBrightnessUp, exec, ~/.config/scripts/brightness-up.sh"
          ", XF86MonBrightnessDown, exec, ~/.config/scripts/brightness-down.sh"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"
          ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          "$mod, F6, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" # Manual mic toggle
          "$mod, F7, exec, ~/.config/scripts/audio-switcher.sh" # Audio device switching

          # Clipboard history
          "$mod, C, exec, cliphist list | wofi --dmenu | cliphist decode | wl-copy"

          # Notification center
          "$mod, N, exec, swaync-client -t"

          # Color temperature controls (Claude-themed)
          "$mod, F1, exec, hyprsunset -t 6500" # Daylight (cool)
          "$mod, F2, exec, hyprsunset -t 5000" # Balanced
          "$mod, F3, exec, hyprsunset -t 4500" # Claude warm (default)
          "$mod, F4, exec, hyprsunset -t 3000" # Very warm (evening)
          "$mod, F5, exec, pkill hyprsunset" # Disable filter

          # Gaming mode toggle (disables effects for performance)
          "$mod, F12, exec, hyprctl --batch \"keyword decoration:blur:enabled false; keyword animations:enabled false\""
          "$mod SHIFT, F12, exec, hyprctl reload" # Restore normal mode
        ];

        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Startup applications with Claude theme integration
        "exec-once" = [
          "hyprpaper" # Start wallpaper first to prevent flash
          "swaync" # Start notification daemon before waybar
          "waybar"
          "hypridle"
          "avizo-service" # Start volume OSD service
        ];

      };
    };
  };

  # Clipboard history service
  systemd.user.services.cliphist = lib.mkIf isWayland {
    Unit = {
      Description = "Clipboard history service";
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  # System maintenance automation
  systemd.user.services.system-maintenance = lib.mkIf (!isISO) {
    Unit.Description = "Automatic system maintenance";
    Service = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "system-maintenance" ''
        set -e

        # Clean up old journal logs
        journalctl --user --vacuum-time=2weeks

        # Clean up old Nix generations (keep last 7)
        nix-collect-garbage --delete-older-than 7d

        # Log maintenance
        echo "$(date): System maintenance completed" >> ~/.local/share/maintenance.log

        ${pkgs.libnotify}/bin/notify-send \
          "System Maintenance" \
          "Automatic cleanup completed" \
          --icon=system-run \
          --category=system
      '';
    };
  };

  systemd.user.timers.system-maintenance = lib.mkIf (!isISO) {
    Unit.Description = "Run system maintenance weekly";
    Timer = {
      OnCalendar = "Sun 02:00";
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };

  # Modern terminal multiplexer (themed by Stylix)
  programs.zellij = lib.mkIf (!isISO) {
    enable = true;
    settings = {
      default_shell = "fish";
      pane_frames = false;
      # Theme handled by Stylix - removed manual theme

      keybinds = {
        normal = {
          "Alt h" = {
            MoveFocus = "Left";
          };
          "Alt l" = {
            MoveFocus = "Right";
          };
          "Alt j" = {
            MoveFocus = "Down";
          };
          "Alt k" = {
            MoveFocus = "Up";
          };
        };
      };
    };
  };

  # Fuzzy finder (manual theming - no Stylix support)
  programs.fzf = lib.mkIf (!isISO) {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--color=bg+:#30302e,bg:#262624,border:#c96442,spinner:#c96442"
      "--color=hl:#c96442,fg:#c2c0b6,header:#c96442,info:#74b9ff"
      "--color=pointer:#c96442,marker:#27ae60,fg+:#f8f7f3,prompt:#c96442"
    ];
    fileWidgetCommand = "fd --type f --hidden --follow --exclude .git";
    changeDirWidgetCommand = "fd --type d --hidden --follow --exclude .git";
  };

  # Smart directory navigation
  programs.zoxide = lib.mkIf (!isISO) {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ]; # Replace cd with smart navigation
  };

  # SwayNotificationCenter configuration files
  xdg.configFile."swaync/config.json" = lib.mkIf (!isISO) {
    text = builtins.toJSON {
      positionX = "right";
      positionY = "top";
      layer = "overlay";
      control-center-layer = "overlay";
      layer-shell = true;
      cssPriority = "application";
      control-center-margin-top = 10;
      control-center-margin-bottom = 10;
      control-center-margin-right = 10;
      control-center-margin-left = 10;
      notification-2fa-action = true;
      notification-inline-replies = false;
      notification-icon-size = 64;
      notification-body-image-height = 100;
      notification-body-image-width = 200;
      timeout = 10;
      timeout-low = 5;
      timeout-critical = 0;
      fit-to-screen = true;
      control-center-width = 500;
      control-center-height = 600;
      notification-window-width = 500;
      keyboard-shortcuts = true;
      image-visibility = "when-available";
      transition-time = 200;
      hide-on-clear = false;
      hide-on-action = true;
      script-fail-notify = true;
    };
  };

  # Waybar configuration with Claude theme - Multi-desktop support
  programs.waybar = lib.mkIf (!isISO) {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 2;

        modules-left = [
          "${if desktop == "hyprland" then "hyprland" else "niri"}/workspaces"
          "custom/dev-env"
        ];
        modules-center = [
          "custom/jasper"
          "${if desktop == "hyprland" then "hyprland" else "niri"}/window"
          "custom/nix-shell"
        ];
        modules-right = [
          "tray"
          "pulseaudio"
          "custom/network"
          "bluetooth"
          "custom/tailscale"
        ]
        ++ lib.optionals (desktop == "hyprland") [
          "custom/containers"
        ]
        ++ lib.optionals (desktop == "niri") [
          "custom/storage"
        ]
        ++ [
          "cpu"
          "memory"
          "temperature"
          "battery"
          "clock"
          "custom/notification"
          "custom/power"
        ];

        "hyprland/workspaces" = lib.mkIf (desktop == "hyprland") {
          disable-scroll = true;
          all-outputs = true;
          format = "{icon}";
          format-icons = {
            "1" = "🏠"; # Home/Main
            "2" = "🌐"; # Web/Browser
            "3" = "📝"; # Editor/Code
            "4" = "📁"; # Files
            "5" = "💬"; # Communication
            "6" = "🎵"; # Media
            "7" = "⚙️"; # Settings/Admin
            "8" = "🎮"; # Games
            "9" = "🖥️"; # VMs/Systems
            "10" = "📋"; # Misc
            "default" = "💼";
            "urgent" = "⚠️";
          };
        };

        "niri/workspaces" = lib.mkIf (desktop == "niri") {
          format = "{icon}";
          format-icons = {
            "1" = "🏠"; # Home/Main
            "2" = "🌐"; # Web/Browser
            "3" = "📝"; # Editor/Code
            "4" = "📁"; # Files
            "5" = "💬"; # Communication
            "6" = "🎵"; # Media
            "7" = "⚙️"; # Settings/Admin
            "8" = "🎮"; # Games
            "9" = "🖥️"; # VMs/Systems
            "10" = "📋"; # Misc
            "default" = "💼";
            "urgent" = "⚠️";
          };
        };

        "hyprland/window" = lib.mkIf (desktop == "hyprland") {
          format = "{}";
          max-length = 50;
          tooltip-format = "Active window: {}";
          on-click = "hyprctl dispatch fullscreen";
          separate-outputs = true;
        };

        "niri/window" = lib.mkIf (desktop == "niri") {
          format = "{}";
          max-length = 50;
          tooltip-format = "Active window: {}";
          on-click = "niri msg action toggle-fullscreen";
        };

        tray = {
          spacing = 5;
          icon-size = 16;
          show-passive-items = false;
        };

        "custom/jasper" = {
          format = "{}";
          tooltip = true;
          interval = 60;
          exec = "/home/tom/git/jasper/waybar-jasper.sh";
          return-type = "json";
          signal = 8;
          on-click = "notify-send 'Jasper' 'Refreshing insights...' && pkill -RTMIN+8 waybar";
        };

        "custom/nix-shell" = {
          format = "{}";
          exec = "if [ -n \"$IN_NIX_SHELL\" ]; then echo '❄️'; else echo ''; fi";
          tooltip-format = "Nix development shell active";
          interval = 5;
        };

        "custom/dev-env" = {
          format = "{}";
          exec = "~/.config/waybar/scripts/dev-env-status.sh";
          on-click = "~/.config/waybar/scripts/dev-env-switcher.sh";
          tooltip = true;
          return-type = "json";
          interval = 10;
        };

        "custom/tailscale" = {
          format = "{}";
          exec = "~/.config/waybar/scripts/tailscale-status.sh";
          on-click = "ghostty -e sudo tailscale up";
          on-click-right = "ghostty -e sudo tailscale down";
          tooltip = true;
          return-type = "json";
          interval = 30;
        };

        "custom/containers" = lib.mkIf (desktop == "hyprland") {
          format = "{}";
          exec = "~/.config/waybar/scripts/containers-status.sh";
          on-click = "lazydocker";
          tooltip = true;
          return-type = "json";
          interval = 30;
        };

        "custom/storage" = lib.mkIf (desktop == "niri") {
          format = "{}";
          exec = "~/.config/waybar/scripts/storage-status.sh";
          on-click = "dua interactive";
          tooltip = true;
          return-type = "json";
          interval = 300;
        };

        "custom/power" = {
          format = "  ⏻  ";
          tooltip-format = "Power Menu";
          on-click = "wlogout";
          on-click-right = "${if desktop == "hyprland" then "hyprlock" else "swaylock-effects"}";
          on-click-middle = "systemctl suspend";
        };

        clock = {
          format = "{:%I:%M %p}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "{usage}%";
          tooltip-format = "CPU Usage: {usage}%";
          on-click = "top";
          on-click-right = "procs";
          interval = 5;
        };

        memory = {
          format = "{percentage}%";
          tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G ({percentage}%)\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G";
          on-click = "top";
          on-click-right = "procs";
          interval = 5;
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°";
          format-critical = "{temperatureC}°";
          tooltip-format = "Temperature: {temperatureC}°C ({temperatureF}°F)";
          format-icons = [
            ""
            ""
            ""
          ];
          interval = 10;
        };

        battery = {
          format = "{capacity}%";
        };

        "custom/network" = {
          exec = "~/.config/waybar/scripts/network-status.sh";
          return-type = "json";
          interval = 10;
          signal = 8;
        };

        "custom/notification" = {
          tooltip = false;
          format = "{icon}";
          format-icons = {
            notification = "<span foreground='red'>🔔</span>";
            none = "🔔";
            dnd-notification = "<span foreground='red'>🔕</span>";
            dnd-none = "🔕";
            inhibited-notification = "<span foreground='red'>🔔</span>";
            inhibited-none = "🔔";
            dnd-inhibited-notification = "<span foreground='red'>🔕</span>";
            dnd-inhibited-none = "🔕";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t";
          on-click-right = "swaync-client -d";
          restart-interval = 1;
          escape = true;
        };

        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-off = "";
          format-connected = " {num_connections}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "Bluetooth: {status}";
          tooltip-format-connected = "Bluetooth: {device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias} ({device_address})";
          tooltip-format-enumerate-connected-battery = "{device_alias} ({device_address})\nBattery: {device_battery_percentage}%";
          on-click = "overskride";
          interval = 30;
          max-length = 25;
        };

        pulseaudio = {
          format = "{volume}% {icon} {format_source}";
          format-bluetooth = "{volume}% {icon} {format_source}";
          format-bluetooth-muted = " {icon} {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          format-icons = {
            headphone = "";
            hands-free = "";
            headset = "";
            phone = "";
            portable = "";
            car = "";
            default = [
              ""
              ""
              ""
            ];
          };
          on-click = "pavucontrol";
          on-click-right = "~/.config/scripts/audio-switcher.sh";
          on-scroll-up = "avizo-client --increase=2";
          on-scroll-down = "avizo-client --decrease=2";
          tooltip-format = "Output: {desc}\nVolume: {volume}%\nSource: {source_desc}\nSource Volume: {source_volume}%";
        };
      };
    };

    # Stylix base + selective Claude terracotta accents
    style = ''
      /* Waybar Inter Nerd Font override */
      * {
        font-family: "Inter Nerd Font", sans-serif;
        font-weight: 400;
      }

      /* Claude signature terracotta border */
      window#waybar {
        border-bottom: 2px solid #d77757;
      }

      /* Enhanced workspace styling with Claude accents */
      #workspaces button {
        padding: 0 8px;
        margin: 0 2px;
        border-radius: 6px;
        font-size: 16px;
        min-width: 28px;
        transition: all 0.2s ease;
      }

      #workspaces button.active {
        background-color: #d77757;
        color: #faf9f5;
      }

      #workspaces button:hover {
        background-color: rgba(215, 119, 87, 0.3);
      }

      #workspaces button.urgent {
        background-color: #ab2b3f;
        color: #faf9f5;
      }

      /* Custom module styling with Claude theme */
      #custom-dev-env, #custom-tailscale,
      #custom-claude-status, #custom-dock-status, #custom-containers,
      #custom-storage {
        padding: 0 8px;
        margin: 0 2px;
        border-radius: 6px;
        transition: all 0.2s ease;
      }

      #custom-dev-env:hover, #custom-tailscale:hover,
      #custom-claude-status:hover, #custom-dock-status:hover, #custom-containers:hover,
      #custom-storage:hover {
        background-color: rgba(215, 119, 87, 0.1);
      }

      /* Development environment indicators */
      #custom-dev-env.rust {
        color: #ce422b;
      }

      #custom-dev-env.web {
        color: #3178c6;
      }

      #custom-dev-env.python {
        color: #3776ab;
      }


      /* Service status indicators */
      #custom-tailscale.connected {
        color: #2c7a39;
      }

      #custom-tailscale.disconnected {
        color: #ab2b3f;
      }

      #custom-claude-status.healthy {
        color: #d77757;
      }

      #custom-claude-status.degraded {
        color: #966c1e;
      }

      #custom-claude-status.offline {
        color: #ab2b3f;
      }

      /* Window title with Claude accent */
      #window {
        color: #d77757;
        font-weight: 500;
      }

      /* Enhanced power button with Claude accent */
      .custom-power {
        border-radius: 6px;
        margin: 0 8px 0 4px;
        padding: 0 8px;
        font-size: 12px;
        transition: all 0.2s ease;
        color: #d77757;
        min-width: 24px;
      }

      .custom-power:hover {
        background-color: rgba(215, 119, 87, 0.2);
        color: #faf9f5;
      }

      /* Subtle hover effects with Claude accent */
      #pulseaudio:hover, #network:hover, #bluetooth:hover,
      #cpu:hover, #memory:hover, #temperature:hover,
      #battery:hover, #clock:hover, #tray:hover, #custom-nix-shell:hover {
        background-color: rgba(215, 119, 87, 0.1);
      }

      /* Critical state indicators with Claude colors */
      #battery.critical:not(.charging) {
        background-color: #ab2b3f;
        color: #faf9f5;
      }

      #temperature.critical {
        background-color: #ab2b3f;
        color: #faf9f5;
      }

      #cpu.warning, #memory.warning {
        background-color: #966c1e;
        color: #faf9f5;
      }

      #battery.charging, #battery.plugged {
        color: #2c7a39;
      }

      /* Jasper Custom Module Styles - Modern border-based design */
      #custom-jasper {
        padding: 0 8px;
        margin: 0 2px;
        background-color: transparent;
        border: 2px solid @base03;
        border-radius: 6px;
        font-weight: 500;
        color: @base05;
        transition: border-color 0.3s ease;
        min-width: 28px;
      }

      #custom-jasper.critical {
        border-color: @base08;
        color: @base08;
        animation: pulse-border 2s infinite;
      }

      #custom-jasper.warning {
        border-color: @base0A;
        color: @base0A;
      }

      #custom-jasper.info {
        border-color: @base0D;
        color: @base0D;
      }

      #custom-jasper.low {
        border-color: @base03;
        color: @base05;
      }

      #custom-jasper.clear {
        border-color: @base0B;
        color: @base0B;
      }

      #custom-jasper.minimal {
        border-color: @base02;
        color: @base05;
      }

      @keyframes pulse {
        0% { opacity: 1; }
        50% { opacity: 0.7; }
        100% { opacity: 1; }
      }

      @keyframes pulse-border {
        0% { border-width: 2px; }
        50% { border-width: 3px; }
        100% { border-width: 2px; }
      }
    '';
  };

  # Wofi launcher configuration with Claude theme
  programs.wofi = lib.mkIf (!isISO) {
    enable = true;
    settings = {
      width = 600;
      height = 400;
      location = "center";
      show = "drun";
      prompt = "Applications";
      filter_rate = 100;
      allow_markup = true;
      no_actions = true;
      halign = "fill";
      orientation = "vertical";
      content_halign = "fill";
      insensitive = true;
      allow_images = true;
      image_size = 40;
      gtk_dark = true;
    };

    style = ''
      window {
        margin: 0px;
        border: 2px solid #d77757; /* Claude's signature terracotta */
        background-color: rgba(31, 30, 29, 0.95); /* Claude's dark background */
        border-radius: 8px;
      }

      #input {
        margin: 5px;
        border: 1px solid #c96442; /* Claude's secondary terracotta */
        color: #faf9f5; /* Claude's light text */
        background-color: rgba(48, 48, 46, 0.8); /* Claude's mid-dark background */
        border-radius: 4px;
        padding: 8px;
        font-size: 14px;
      }

      #input:focus {
        border: 1px solid #d77757; /* Claude brand focus */
      }

      #inner-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #outer-box {
        margin: 5px;
        border: none;
        background-color: transparent;
      }

      #scroll {
        margin: 0px;
        border: none;
      }

      #text {
        margin: 5px;
        border: none;
        color: #faf9f5; /* Claude's light text */
      }

      #entry {
        background-color: transparent;
        margin: 2px;
        padding: 8px;
        border-radius: 4px;
      }

      #entry:selected {
        background-color: #d77757; /* Claude's signature terracotta */
        color: #faf9f5;
      }

      #entry:hover {
        background-color: rgba(217, 119, 87, 0.3); /* Claude brand with opacity */
      }

      #text:selected {
        color: #faf9f5;
      }

      #img {
        margin-right: 8px;
      }
    '';
  };

  # GTK theme configuration - let Stylix handle base theme
  gtk = lib.optionalAttrs (desktop == "hyprland") {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  # Qt theme configuration - let Stylix handle theming
  qt = lib.optionalAttrs (desktop == "hyprland") {
    enable = true;
  };

  # Hyprpaper configuration now managed by Stylix autoEnable

  # Hypridle configuration (idle management) - only for Hyprland
  home.file.".config/hypr/hypridle.conf" = lib.mkIf (desktop == "hyprland") {
    text = ''
      general {
        lock_cmd = pidof hyprlock || hyprlock
        before_sleep_cmd = loginctl lock-session
        after_sleep_cmd = hyprctl dispatch dpms on
      }

      listener {
        timeout = 300  # 5 minutes
        on-timeout = loginctl lock-session
      }

      listener {
        timeout = 330  # 5.5 minutes
        on-timeout = hyprctl dispatch dpms off
        on-resume = hyprctl dispatch dpms on
      }

      listener {
        timeout = 1800  # 30 minutes
        on-timeout = systemctl suspend
      }
    '';
  };

  # Hyprlock configuration (Claude-themed screen lock) - only for Hyprland
  home.file.".config/hypr/hyprlock.conf" = lib.mkIf (desktop == "hyprland") {
    text = ''
      general {
        grace = 300
        hide_cursor = true
      }

      background {
        monitor =
        path = /home/tom/Pictures/Wallpapers/astro.png
        blur_passes = 3
        blur_size = 8
        noise = 0.0117
        contrast = 0.8916
        brightness = 0.8172
        vibrancy = 0.1696
        vibrancy_darkness = 0.0
      }

      input-field {
        monitor =
        size = 200, 50
        outline_thickness = 3
        dots_size = 0.33
        dots_spacing = 0.15
        dots_center = true
        dots_rounding = -1
        outer_color = rgb(d77757)  # Claude's signature terracotta
        inner_color = rgb(1f1e1d)  # Claude's dark background
        font_color = rgb(faf9f5)   # Claude's light text
        fade_on_empty = true
        fade_timeout = 1000
        placeholder_text = <i>Input Password...</i>
        hide_input = false
        rounding = 8
        check_color = rgb(2c7a39)  # Claude's success green
        fail_color = rgb(ab2b3f)   # Claude's error red
        fail_text = <i>$FAIL <b>($ATTEMPTS)</b></i>
        capslock_color = rgb(966c1e)  # Claude's warning amber
        numlock_color = -1
        bothlock_color = -1
        invert_numlock = false
        swap_font_color = false

        position = 0, -20
        halign = center
        valign = center
      }

      label {
        monitor =
        text = cmd[update:1000] bash -c 'hour=$(date +%H); if [ $hour -lt 6 ]; then msg="Still up"; elif [ $hour -lt 9 ]; then msg="Good morning"; elif [ $hour -lt 12 ]; then msg="Morning"; elif [ $hour -lt 17 ]; then msg="Good afternoon"; elif [ $hour -lt 21 ]; then msg="Good evening"; else msg="Evening"; fi; user=$(echo $USER | sed "s/./\U&/"); echo "$msg, $user"'
        color = rgb(faf9f5)  # Claude's light text
        font_size = 20
        font_family = Inter Nerd Font
        rotate = 0

        position = 0, 80
        halign = center
        valign = center
      }

      label {
        monitor =
        text = $TIME12
        color = rgb(d77757)  # Claude's signature terracotta
        font_size = 55
        font_family = Inter Nerd Font
        rotate = 0

        position = 0, 160
        halign = center
        valign = center
      }
    '';
  };

  # Manual wlogout configuration with Claude theming - only for Hyprland
  programs.wlogout = lib.mkIf (desktop == "hyprland") {
    enable = true;
    style = ''
      * {
        background-image: none;
        font-family: "Inter Nerd Font";
        font-size: 20px;
      }

      window {
        background-color: rgba(26, 25, 21, 0.95);
      }

      button {
        color: #faf9f5;
        background-color: rgba(31, 30, 29, 0.9);
        border: 2px solid rgba(215, 119, 87, 0.6);
        border-radius: 20px;
        margin: 20px;
        padding: 20px;
        transition: all 0.3s ease;
        outline-style: none;
        min-width: 200px;
        min-height: 200px;
      }

      button:hover {
        background-color: rgba(215, 119, 87, 0.15);
        border-color: #d77757;
      }

      button:focus {
        background-color: rgba(215, 119, 87, 0.25);
        border-color: #d77757;
        box-shadow: 0 0 20px rgba(215, 119, 87, 0.4);
      }

      label {
        margin-top: 10px;
        font-weight: bold;
      }

      #lock {
        color: #7fc8ff;
      }

      #logout {
        color: #966c1e;
      }

      #suspend {
        color: #c96442;
      }

      #hibernate {
        color: #5a9fd4;
      }

      #shutdown {
        color: #ab2b3f;
      }

      #reboot {
        color: #2c7a39;
      }
    '';
  };

  # Stylix Home Manager targets - comprehensive application theming
  stylix.targets = lib.optionalAttrs (!isISO) {
    # Desktop environment theming
    waybar.enable = true;
    wofi.enable = true;

    # Terminal and shell theming
    ghostty.enable = true;
    fish.enable = true;
    starship.enable = true;

    # Application theming
    swaync.enable = true;
    avizo.enable = true;
    vscode.enable = true;

    # GTK CSS override to fix button text visibility
    gtk.extraCss = ''
      dialog button,
      .dialog button,
      messagedialog button,
      window.dialog button {
        color: #f8f7f3 !important;
      }
    '';
  };

  # Hyprpaper configuration with astronaut wallpaper
  home.file.".config/hypr/hyprpaper.conf" = lib.mkIf (desktop == "hyprland") {
    text = ''
      preload = /home/tom/Pictures/Wallpapers/astro.png
      wallpaper = eDP-1,/home/tom/Pictures/Wallpapers/astro.png
      wallpaper = DP-2,/home/tom/Pictures/Wallpapers/astro.png
      wallpaper = DP-3,/home/tom/Pictures/Wallpapers/astro.png
      wallpaper = DP-4,/home/tom/Pictures/Wallpapers/astro.png
      splash = false
      ipc = on
    '';
  };

}
