{
  pkgs,
  inputs,
  lib,
  desktop ? "gnome",
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
    # sudo = "sudo-rs";  # Disabled until system rebuild completes
    # Core utilities (most common first)
    cp = "uutils-cp";
    mv = "uutils-mv";
    rm = "uutils-rm";
    mkdir = "uutils-mkdir";
    rmdir = "uutils-rmdir";
    touch = "uutils-touch";
    chmod = "uutils-chmod";
    chown = "uutils-chown";
    # Text processing
    sort = "uutils-sort";
    uniq = "uutils-uniq";
    cut = "uutils-cut";
    head = "uutils-head";
    tail = "uutils-tail";
    wc = "uutils-wc";
    # File operations
    stat = "uutils-stat";
    ln = "uutils-ln";
    # System info
    whoami = "uutils-whoami";
    id = "uutils-id";
    groups = "uutils-groups";
    # Path utilities
    basename = "uutils-basename";
    dirname = "uutils-dirname";
    readlink = "uutils-readlink";
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
  programs =
    {
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
    }

    # Hyprland-specific configuration
    // lib.optionalAttrs (desktop == "hyprland") {
      # Hyprland window manager configuration
      wayland.windowManager.hyprland = {
        enable = true;
        package = inputs.hyprland.packages.${pkgs.system}.hyprland;
        settings = {
          # Monitor configuration (will auto-detect)
          monitor = [ ",preferred,auto,1" ];

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
            "col.active_border" = "rgb(d97757) rgb(c96442) 45deg";
            "col.inactive_border" = "rgb(30302e)";

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

            # Claude's shadow system
            drop_shadow = true;
            shadow_range = 12;
            shadow_render_power = 3;
            "col.shadow" = "rgba(1f1e1d99)"; # Claude's dark background with opacity

            # Blur settings with Claude's refined aesthetic
            blur = {
              enabled = true;
              size = 6;
              passes = 2;
              new_optimizations = true;
              xray = false;
              ignore_opacity = false;
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

          # Workspace rules with Claude's semantic color system
          workspace = [
            "1, border_color:rgb(2c7a39)" # Success workspace (development/terminal)
            "2, border_color:rgb(d97757)" # Claude brand workspace (main work)
            "3, border_color:rgb(966c1e)" # Warning workspace (monitoring/logs)
            "4, border_color:rgb(ab2b3f)" # Error workspace (debugging)
            "5, border_color:rgb(5769f7)" # Permission workspace (admin tasks)
            "6, border_color:rgb(006666)" # Plan mode workspace (planning/design)
          ];

          # Window rules with Claude theme colors for installed packages
          windowrule = [
            "float, ^(pavucontrol)$"
            "float, ^(thunar)$"
            "size 800 600, ^(thunar)$"
            "bordercolor rgb(215 119 87), ^(ghostty)$"
            "bordercolor rgb(194 192 182), ^(thunar)$"
            "bordercolor rgb(201 100 66), ^(mpv)$"
            "bordercolor rgb(201 100 66), ^(imv)$"
          ];

          # Keybindings - using Super (Windows/Cmd) key
          "$mod" = "SUPER";

          # Application launchers with Claude theme awareness
          bind = [
            "$mod, Return, exec, ghostty"
            "$mod, D, exec, wofi --show drun"
            "$mod, E, exec, thunar"

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

            # Screenshot
            ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"
            "$mod, Print, exec, grim - | wl-copy"

            # Media keys
            ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
            ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
            ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
            ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
            ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
            ", XF86AudioPlay, exec, playerctl play-pause"
            ", XF86AudioNext, exec, playerctl next"
            ", XF86AudioPrev, exec, playerctl previous"
          ];

          # Mouse bindings
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];

          # Startup applications with Claude theme integration
          "exec-once" = [
            "waybar"
            "swaync"
            "swayidle -w timeout 300 'swaylock-effects' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock-effects'"
            "swaybg -i ~/.config/wallpaper.jpg -m fill"
          ];
        };
      };
    };
}
