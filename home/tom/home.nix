{
  pkgs,
  config,
  inputs,
  desktop ? "gnome",
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
    
    # Gaming tools
    protonup-qt   # GUI tool for managing Proton versions
  ];

  # Dotfiles (currently managed through GUI/sync)
  home.file = {};

  # Services
  services.ssh-agent.enable = true;

  # GitHub CLI is configured to use encrypted token
  # Authentication can be done manually: gh auth login --with-token < /run/secrets/github_token

  # Environment variables
  home.sessionVariables = {
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "$HOME/.steam/root/compatibilitytools.d";
    EDITOR = "micro";
    SYSTEMD_EDITOR = "micro";
    VISUAL = "micro";
  };

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
        nano = "micro";
        gh-auth = "gh auth login --with-token < /run/secrets/github_token";
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
        nano = "micro";
        gh-auth = "gh auth login --with-token < /run/secrets/github_token";
      };
      interactiveShellInit = ''
        # Ghostty-specific optimizations
        if test "$TERM_PROGRAM" = "ghostty"
          alias clear='printf "\033[2J\033[3J\033[1;1H"'
          alias reload='source ~/.config/fish/config.fish'
        end
      '';
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
      extraConfig = ''
        # Use encrypted SSH key from secrets
        IdentityFile /run/secrets/ssh_private_key
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
    };
  } // (if desktop == "hyprland" then {
    # Hyprland window manager configuration
    hyprland = {
      enable = true;
      package = inputs.hyprland.packages.${pkgs.system}.hyprland;
      
      settings = {
        # Monitor configuration (will auto-detect)
        monitor = [
          ",preferred,auto,1"
        ];
        
        # Input configuration - maintain Colemak layout
        input = {
          kb_layout = "us";
          kb_variant = "colemak";
          follow_mouse = 1;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
          };
          sensitivity = 0;
        };
        
        # General settings
        general = {
          gaps_in = 5;
          gaps_out = 10;
          border_size = 2;
          "col.active_border" = "rgba(33ccffee) rgba(00ff99ee) 45deg";
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          allow_tearing = false;
        };
        
        # Decoration
        decoration = {
          rounding = 8;
          blur = {
            enabled = true;
            size = 3;
            passes = 1;
          };
          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
          "col.shadow" = "rgba(1a1a1aee)";
        };
        
        # Animations
        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
        
        # Layout
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        
        # Window rules for common applications
        windowrule = [
          "float, ^(pavucontrol)$"
          "float, ^(thunar)$"
          "size 800 600, ^(thunar)$"
        ];
        
        # Keybindings - using Super (Windows/Cmd) key
        "$mod" = "SUPER";
        bind = [
          # Application launchers
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
          
          # Workspaces
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
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
        
        # Startup applications
        exec-once = [
          "waybar"
          "mako"
          "swayidle -w timeout 300 'swaylock-effects' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock-effects'"
          "swaybg -i ~/.config/wallpaper.jpg -m fill"
        ];
      };
    };
  } else {});
}