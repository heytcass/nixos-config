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
  imports = lib.optionals (desktop == "hyprland") [ inputs.hyprland.homeManagerModules.default ];
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

      # Bluetooth management tools
      overskride # Modern GTK4 Bluetooth manager
      bluetui # TUI Bluetooth manager for terminal use

    ];

    # Dotfiles (currently managed through GUI/sync)
    file = { };

    # GitHub CLI is configured to use encrypted token
    # Authentication can be done manually: gh auth login --with-token < /run/secrets/github_token

    # Environment variables
    sessionVariables =
      {
        STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      }
      // lib.optionalAttrs (desktop == "hyprland") {
        # Force dark theme for applications
        GTK_THEME = "Adwaita:dark";
        QT_STYLE_OVERRIDE = "adwaita-dark";

        # Cursor theme
        XCURSOR_THEME = "Bibata-Modern-Classic";
        XCURSOR_SIZE = "24";

        # Claude-themed terminal colors for applications that support it
        CLAUDE_BRAND_COLOR = "#d77757";
        CLAUDE_DARK_BG = "#1f1e1d";
        CLAUDE_LIGHT_FG = "#faf9f5";
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

      # Plugins configuration - no plugins loaded
      plugins = [ ];
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

          # Claude's shadow system (updated for 0.49.0)
          shadow = {
            enabled = true;
            range = 12;
            render_power = 3;
            color = "0x991f1e1d"; # Claude's dark background with opacity
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

        # Workspace rules with Claude's semantic color system
        workspace = [
          "1, border_color:rgb(2c7a39)" # Success workspace (development/terminal)
          "2, border_color:rgb(d97757)" # Claude brand workspace (main work)
          "3, border_color:rgb(966c1e)" # Warning workspace (monitoring/logs)
          "4, border_color:rgb(ab2b3f)" # Error workspace (debugging)
          "5, border_color:rgb(5769f7)" # Permission workspace (admin tasks)
          "6, border_color:rgb(006666)" # Plan mode workspace (planning/design)
        ];

        # Cursor configuration for Hyprland
        env = [
          "XCURSOR_THEME,Bibata-Modern-Classic"
          "XCURSOR_SIZE,24"
        ];

        # Window rules with Claude theme colors for installed packages
        windowrulev2 = [
          "float, class:^(pavucontrol)$"
          "float, class:^(thunar)$"
          "size 800 600, class:^(thunar)$"
          "bordercolor rgb(d77757), class:^(ghostty)$"
          "bordercolor rgb(c2c0b6), class:^(thunar)$"
          "bordercolor rgb(c96442), class:^(mpv)$"
          "bordercolor rgb(c96442), class:^(imv)$"
        ];

        # Keybindings - using Super (Windows/Cmd) key
        "$mod" = "SUPER";

        # Application launchers with Claude theme awareness
        bind = [
          "$mod, Return, exec, ghostty"
          "$mod, space, exec, wofi --show drun"
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

          # Screenshot - save to Pictures/Screenshots/
          ", Print, exec, mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png"
          "$mod, Print, exec, mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/screenshot-$(date +%Y%m%d_%H%M%S).png"

          # Screenshot to clipboard (Shift variants)
          "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mod SHIFT, Print, exec, grim - | wl-copy"

          # Media keys
          ", XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%"
          ", XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%"
          ", XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle"
          ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
          ", XF86AudioPlay, exec, playerctl play-pause"
          ", XF86AudioNext, exec, playerctl next"
          ", XF86AudioPrev, exec, playerctl previous"

          # Color temperature controls (Claude-themed)
          "$mod, F1, exec, hyprsunset -t 6500" # Daylight (cool)
          "$mod, F2, exec, hyprsunset -t 5000" # Balanced
          "$mod, F3, exec, hyprsunset -t 4500" # Claude warm (default)
          "$mod, F4, exec, hyprsunset -t 3000" # Very warm (evening)
          "$mod, F5, exec, pkill hyprsunset" # Disable filter
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
          "hypridle"
          "hyprpaper"
          "hyprsunset -t 4500" # Warm color temperature matching Claude's terracotta theme
        ];

      };
    };
  };

  # Waybar configuration with Claude theme
  programs.waybar = lib.optionalAttrs (desktop == "hyprland") {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;
        spacing = 4;

        modules-left = [
          "hyprland/workspaces"
          "custom/separator"
          "hyprland/window"
        ];
        modules-center = [ ];
        modules-right = [
          "pulseaudio"
          "network"
          "bluetooth"
          "custom/nix-shell"
          "custom/git-status"
          "custom/separator"
          "cpu"
          "memory"
          "temperature"
          "custom/separator"
          "battery"
          "clock"
          "tray"
        ];

        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          format = "{name}: {icon}";
          format-icons = {
            "1" = "󰅨";
            "2" = "󰖟";
            "3" = "󰍉";
            "4" = "󰃤";
            "5" = "󰀻";
            "6" = "󰸗";
            "default" = "󰝤";
            "urgent" = "󰀨";
          };
          persistent-workspaces = {
            "*" = 6;
          };
        };

        "hyprland/window" = {
          format = "{}";
          max-length = 30;
          tooltip-format = "Active window: {}";
          on-click = "hyprctl dispatch fullscreen";
          separate-outputs = true;
        };

        tray = {
          spacing = 10;
          icon-size = 16;
        };

        "custom/separator" = {
          format = "|";
          tooltip = false;
        };

        "custom/nix-shell" = {
          format = "{}";
          exec = "if [ -n \"$IN_NIX_SHELL\" ]; then echo '❄️'; else echo ''; fi";
          tooltip-format = "Nix development shell active";
          interval = 5;
        };

        "custom/git-status" = {
          format = "{}";
          return-type = "json";
          exec = ''
            if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
              branch=$(git branch --show-current 2>/dev/null || echo "unknown")
              if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                changes=$(git status --porcelain 2>/dev/null | wc -l)
                echo "{\"text\": \" $branch\", \"class\": \"git-dirty\", \"tooltip\": \"Git: $branch ($changes changes)\"}"
              else
                echo "{\"text\": \" $branch\", \"class\": \"git-clean\", \"tooltip\": \"Git: $branch (clean)\"}"
              fi
            else
              echo "{\"text\": \"\", \"class\": \"git-none\", \"tooltip\": \"Not in git repository\"}"
            fi
          '';
          on-click = "ghostty -e git status";
          interval = 15;
        };

        clock = {
          format = "{:%H:%M}";
          format-alt = "{:%Y-%m-%d}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        cpu = {
          format = "{usage}% ";
          tooltip-format = "CPU Usage: {usage}%";
          on-click = "top";
          on-click-right = "procs";
          interval = 5;
        };

        memory = {
          format = "{percentage}% ";
          tooltip-format = "RAM: {used:0.1f}G / {total:0.1f}G ({percentage}%)\nSwap: {swapUsed:0.1f}G / {swapTotal:0.1f}G";
          on-click = "top";
          on-click-right = "procs";
          interval = 5;
        };

        temperature = {
          critical-threshold = 80;
          format = "{temperatureC}°C {icon}";
          format-critical = "{temperatureC}°C {icon}";
          tooltip-format = "Temperature: {temperatureC}°C ({temperatureF}°F)";
          format-icons = [
            ""
            ""
            ""
          ];
          interval = 10;
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{capacity}% {icon}";
          format-charging = "{capacity}% ";
          format-plugged = "{capacity}% ";
          tooltip-format = "Battery: {capacity}%";
          format-icons = [
            ""
            ""
            ""
            ""
            ""
          ];
          interval = 30;
          swap-icon-label = false;
        };

        network = {
          format-wifi = "{essid} ";
          format-ethernet = "󰈀 Connected";
          format-linked = "󰈀 No IP";
          format-disconnected = "󰈂 Disconnected";
          tooltip-format-wifi = "WiFi: {essid} ({signalStrength}%)\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}";
          tooltip-format-ethernet = "Ethernet: {ifname}\nIP: {ipaddr}/{cidr}\nGateway: {gwaddr}";
          interval = 10;
          swap-icon-label = false;
        };

        bluetooth = {
          format = " {status}";
          format-disabled = "";
          format-off = "";
          format-connected = " {num_connections}";
          format-connected-battery = " {device_alias} {device_battery_percentage}%";
          tooltip-format = "Bluetooth: {status}";
          tooltip-format-connected = "Bluetooth: {device_enumerate}";
          tooltip-format-enumerate-connected = "{device_alias}\\t{device_address}";
          tooltip-format-enumerate-connected-battery = "{device_alias}\\t{device_address}\\t{device_battery_percentage}%";
          on-click = "overskride";
          on-click-right = "bluetui";
          interval = 30;
          max-length = 25;
        };

        pulseaudio = {
          format = "{volume}% {icon}";
          format-bluetooth = "{volume}% {icon}";
          format-bluetooth-muted = " {icon}";
          format-muted = " ";
          format-source = "{volume}% ";
          format-source-muted = "";
          tooltip-format = "Audio: {volume}% ({desc})\nSource: {source_volume}%";
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
          swap-icon-label = false;
        };
      };
    };

    style = ''
      * {
        font-family: 'Inter', sans-serif;
        font-size: 13px;
      }

      window#waybar {
        background-color: rgba(31, 30, 29, 0.9); /* Claude's dark background */
        border-bottom: 2px solid #d77757; /* Claude's signature terracotta */
        color: #faf9f5; /* Claude's light text */
        transition-property: background-color;
        transition-duration: .5s;
      }

      button {
        box-shadow: inset 0 -3px transparent;
        border: none;
        border-radius: 0;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #c2c0b6; /* Claude's mid gray */
      }

      #workspaces button:hover {
        background: rgba(217, 119, 87, 0.2); /* Claude brand with opacity */
      }

      #workspaces button.active {
        background-color: #d77757; /* Claude's signature terracotta */
        color: #faf9f5;
      }

      #workspaces button.urgent {
        background-color: #ab2b3f; /* Claude's error red */
      }


      #clock,
      #battery,
      #cpu,
      #memory,
      #temperature,
      #network,
      #pulseaudio,
      #tray {
        padding: 0 10px;
        color: #faf9f5;
      }

      #pulseaudio:hover,
      #network:hover,
      #cpu:hover,
      #memory:hover,
      #temperature:hover,
      #battery:hover,
      #clock:hover {
        background-color: rgba(217, 119, 87, 0.1);
      }

      .custom-separator1,
      .custom-separator2 {
        color: #c2c0b6;
        padding: 0 8px;
        opacity: 0.5;
      }

      #cpu,
      #memory,
      #temperature {
        background-color: rgba(150, 108, 30, 0.1);
        border-radius: 4px;
        margin: 2px;
      }

      #battery {
        background-color: rgba(44, 122, 57, 0.1);
        border-radius: 4px;
        margin: 2px;
      }

      .custom-nix-shell {
        color: #5bc0de;
        background-color: rgba(91, 192, 222, 0.1);
        border-radius: 4px;
        margin: 2px;
        padding: 0 8px;
        font-size: 14px;
      }

      #custom-git-status {
        padding: 0 8px;
        margin: 2px;
        border-radius: 4px;
      }

      #custom-git-status.git-clean {
        color: #2c7a39; /* Claude's success green */
        border-color: rgba(44, 122, 57, 0.7);
      }

      #custom-git-status.git-dirty {
        color: #966c1e; /* Claude's warning amber */
        border-color: rgba(150, 108, 30, 0.7);
      }

      #custom-git-status.git-error {
        color: #ab2b3f; /* Claude's error red */
        border-color: rgba(171, 43, 63, 0.7);
      }

      #window {
        color: #d77757; /* Claude brand for window title */
      }

      #custom-media {
        color: #2c7a39; /* Claude's success green */
        padding: 0 10px;
      }

      #custom-media.media-playing {
        color: #2c7a39; /* Claude's success green */
        animation: pulse 2s infinite;
      }

      #custom-media.media-paused {
        color: #966c1e; /* Claude's warning amber */
      }

      #custom-media.media-stopped {
        color: #525152; /* Claude's muted gray */
      }

      #custom-weather {
        color: #7fc8ff; /* Claude's blue */
        padding: 0 10px;
      }

      #custom-weather.weather-error {
        color: #ab2b3f; /* Claude's error red */
      }

      #battery.charging, #battery.plugged {
        color: #2c7a39; /* Claude's success green */
        border-color: rgba(44, 122, 57, 0.7);
      }

      #battery.critical:not(.charging) {
        background-color: #ab2b3f; /* Claude's error red */
        border-color: #ab2b3f;
        color: #faf9f5;
        animation-name: blink;
        animation-duration: 0.5s;
        animation-timing-function: linear;
        animation-iteration-count: infinite;
        animation-direction: alternate;
      }

      #temperature.critical {
        background-color: #ab2b3f; /* Claude's error red */
        border-color: #ab2b3f;
        color: #faf9f5;
      }

      #cpu.warning {
        background-color: #966c1e; /* Claude's warning amber */
        border-color: #966c1e;
        color: #faf9f5;
        animation: pulse 2s infinite;
      }

      #memory.warning {
        background-color: #966c1e; /* Claude's warning amber */
        border-color: #966c1e;
        color: #faf9f5;
        animation: pulse 2s infinite;
      }

      #bluetooth {
        color: #c2c0b6; /* Claude's mid gray for default state */
        background-color: rgba(26, 25, 21, 0.8); /* Claude's darker background */
        padding: 0 10px;
        border-radius: 6px;
        margin: 0 2px;
        border: 1px solid rgba(215, 119, 87, 0.3); /* Subtle Claude terracotta border */
        transition: all 0.3s ease;
      }

      #bluetooth.connected {
        color: #d77757; /* Claude's terracotta when connected */
        background-color: rgba(215, 119, 87, 0.1); /* Light terracotta background */
        border-color: #d77757;
        animation: pulse-bluetooth 2s infinite;
      }

      #bluetooth.disabled, #bluetooth.off {
        color: #525152; /* Claude's dark gray for disabled */
        background-color: transparent;
        border-color: rgba(82, 81, 82, 0.3);
      }

      #bluetooth:hover {
        background-color: rgba(215, 119, 87, 0.2); /* Claude terracotta on hover */
        border-color: #d77757;
        box-shadow: 0 4px 12px rgba(215, 119, 87, 0.4), 0 2px 6px rgba(215, 119, 87, 0.2);
      }

      /* Apply Bluetooth-style rounded borders to all modules */
      #pulseaudio, #network, #custom-nix-shell, #custom-git-status,
      #cpu, #memory, #temperature, #battery, #clock, #tray {
        background-color: rgba(26, 25, 21, 0.8) !important; /* Claude's darker background */
        border-radius: 6px !important;
        margin: 0 2px !important;
        border: 1px solid rgba(215, 119, 87, 0.3) !important; /* Subtle Claude terracotta border */
        transition: all 0.3s ease !important;
      }

      /* Apply consistent hover effects to all modules */
      #pulseaudio:hover, #network:hover, #custom-nix-shell:hover,
      #custom-git-status:hover, #cpu:hover, #memory:hover,
      #temperature:hover, #battery:hover, #clock:hover, #tray:hover {
        background-color: rgba(215, 119, 87, 0.2) !important; /* Claude terracotta on hover */
        border-color: #d77757 !important;
        box-shadow: 0 4px 12px rgba(215, 119, 87, 0.4), 0 2px 6px rgba(215, 119, 87, 0.2) !important;
      }

      @keyframes pulse-bluetooth {
        0% {
          border-color: #d77757;
          box-shadow: 0 0 0 0 rgba(215, 119, 87, 0.4);
        }
        50% {
          border-color: #c96442;
          box-shadow: 0 0 0 3px rgba(215, 119, 87, 0.2);
        }
        100% {
          border-color: #d77757;
          box-shadow: 0 0 0 0 rgba(215, 119, 87, 0.4);
        }
      }

      @keyframes pulse {
        0% { opacity: 1; }
        50% { opacity: 0.7; }
        100% { opacity: 1; }
      }

      @keyframes blink {
        to {
          background-color: #faf9f5;
          color: #1f1e1d;
        }
      }
    '';
  };

  # Wofi launcher configuration with Claude theme
  programs.wofi = lib.optionalAttrs (desktop == "hyprland") {
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

  # GTK theme configuration with Claude dark theme customization
  gtk = lib.optionalAttrs (desktop == "hyprland") {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
      size = 24;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };

    # Custom Claude-themed CSS for GTK3
    gtk3.extraCss = ''
      /* Claude Dark Theme Colors */
      @define-color claude_primary #c15f3c;        /* Claude's Crail terra cotta */
      @define-color claude_secondary #b1ada1;      /* Claude's Cloudy gray */
      @define-color claude_light_bg #f4f3ee;       /* Claude's Pampas light */
      @define-color claude_dark_bg #2a2a2a;        /* Dark background */
      @define-color claude_darker_bg #1e1e1e;      /* Darker background */
      @define-color claude_text_light #f4f3ee;     /* Light text on dark */
      @define-color claude_text_dark #1a1915;      /* Dark text on light */
      @define-color claude_accent_hover #d77757;   /* Lighter terra cotta for hover */
      @define-color claude_accent_active #a54d2c;  /* Darker terra cotta for active */
      @define-color claude_border #3e3e38;         /* Border color */

      /* Override accent colors with Claude theme */
      @define-color accent_color @claude_primary;
      @define-color accent_bg_color @claude_primary;
      @define-color accent_fg_color @claude_text_light;

      /* Button styling with Claude colors */
      button {
        border: 1px solid @claude_border;
      }

      button.suggested-action {
        background-image: linear-gradient(@claude_primary, @claude_accent_active);
        border-color: @claude_accent_active;
        color: @claude_text_light;
      }

      button.suggested-action:hover {
        background-image: linear-gradient(@claude_accent_hover, @claude_primary);
        border-color: @claude_primary;
      }

      button.suggested-action:active {
        background-image: linear-gradient(@claude_accent_active, shade(@claude_accent_active, 0.8));
        border-color: @claude_accent_active;
      }

      /* Selection and highlighting */
      selection,
      *:selected {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Text input focus styling */
      entry:focus,
      textview:focus {
        border-color: @claude_primary;
        box-shadow: 0 0 0 1px @claude_primary;
      }

      /* Scrollbars with Claude theme */
      scrollbar slider {
        background-color: @claude_secondary;
      }

      scrollbar slider:hover {
        background-color: @claude_primary;
      }

      /* Menu item highlighting */
      menuitem:hover {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Headerbar with Claude accents */
      headerbar {
        border-bottom: 1px solid @claude_border;
      }

      headerbar button.suggested-action {
        background-image: linear-gradient(@claude_primary, @claude_accent_active);
        border-color: @claude_accent_active;
        color: @claude_text_light;
      }

      /* Switch control with Claude colors */
      switch:checked {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Progress bars */
      progressbar progress {
        background-color: @claude_primary;
      }

      /* Links */
      link,
      link:link {
        color: @claude_primary;
      }

      link:visited {
        color: @claude_secondary;
      }

      link:hover {
        color: @claude_accent_hover;
      }
    '';

    # Custom Claude-themed CSS for GTK4
    gtk4.extraCss = ''
      /* Claude Dark Theme Colors for GTK4 */
      @define-color claude_primary #c15f3c;        /* Claude's Crail terra cotta */
      @define-color claude_secondary #b1ada1;      /* Claude's Cloudy gray */
      @define-color claude_light_bg #f4f3ee;       /* Claude's Pampas light */
      @define-color claude_dark_bg #2a2a2a;        /* Dark background */
      @define-color claude_darker_bg #1e1e1e;      /* Darker background */
      @define-color claude_text_light #f4f3ee;     /* Light text on dark */
      @define-color claude_text_dark #1a1915;      /* Dark text on light */
      @define-color claude_accent_hover #d77757;   /* Lighter terra cotta for hover */
      @define-color claude_accent_active #a54d2c;  /* Darker terra cotta for active */
      @define-color claude_border #3e3e38;         /* Border color */

      /* Override accent colors with Claude theme */
      @define-color accent_color @claude_primary;
      @define-color accent_bg_color @claude_primary;
      @define-color accent_fg_color @claude_text_light;

      /* Button styling with Claude colors */
      .suggested-action {
        background: @claude_primary;
        border-color: @claude_accent_active;
        color: @claude_text_light;
      }

      .suggested-action:hover {
        background: @claude_accent_hover;
        border-color: @claude_primary;
      }

      .suggested-action:active {
        background: @claude_accent_active;
        border-color: @claude_accent_active;
      }

      /* Selection and highlighting */
      selection {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Text input focus styling */
      entry:focus-within {
        border-color: @claude_primary;
        outline-color: @claude_primary;
      }

      /* Scrollbars with Claude theme */
      scrollbar slider {
        background-color: @claude_secondary;
      }

      scrollbar slider:hover {
        background-color: @claude_primary;
      }

      /* Menu item highlighting */
      popover.menu menuitem:hover {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Headerbar with Claude accents */
      headerbar {
        border-bottom: 1px solid @claude_border;
      }

      headerbar .suggested-action {
        background: @claude_primary;
        border-color: @claude_accent_active;
        color: @claude_text_light;
      }

      /* Switch control with Claude colors */
      switch:checked {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Progress bars */
      progressbar > trough > progress {
        background-color: @claude_primary;
      }

      /* Links */
      link {
        color: @claude_primary;
      }

      link:visited {
        color: @claude_secondary;
      }

      link:hover {
        color: @claude_accent_hover;
      }

      /* Tabs */
      tabbox > tablist > tab:checked {
        background-color: @claude_primary;
        color: @claude_text_light;
      }

      /* Check and radio buttons */
      checkbutton:checked,
      radiobutton:checked {
        color: @claude_primary;
      }

      /* Spinner and loading indicators */
      spinner {
        color: @claude_primary;
      }
    '';
  };

  # Qt theme configuration to match GTK
  qt = lib.optionalAttrs (desktop == "hyprland") {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
  };

  # Hyprpaper configuration (Claude-themed wallpaper)
  home.file.".config/hypr/hyprpaper.conf" = lib.optionalAttrs (desktop == "hyprland") {
    text = ''
      preload = /home/tom/Pictures/Wallpapers/astro.png
      wallpaper = ,/home/tom/Pictures/Wallpapers/astro.png
      splash = false
      ipc = on
    '';
  };

  # Hypridle configuration (idle management)
  home.file.".config/hypr/hypridle.conf" = lib.optionalAttrs (desktop == "hyprland") {
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

  # Hyprlock configuration (Claude-themed screen lock)
  home.file.".config/hypr/hyprlock.conf" = lib.optionalAttrs (desktop == "hyprland") {
    text = ''
      general {
        disable_loading_bar = true
        grace = 300
        hide_cursor = true
        no_fade_in = false
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
        fail_transition = 300
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
        text = Hi there, $USER
        color = rgb(faf9f5)  # Claude's light text
        font_size = 20
        font_family = Inter
        rotate = 0

        position = 0, 80
        halign = center
        valign = center
      }

      label {
        monitor =
        text = $TIME
        color = rgb(d77757)  # Claude's signature terracotta
        font_size = 55
        font_family = Inter
        rotate = 0

        position = 0, 160
        halign = center
        valign = center
      }
    '';
  };
}
