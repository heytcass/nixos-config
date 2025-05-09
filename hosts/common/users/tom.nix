{ pkgs, unstable, inputs, lib, config, osConfig, ... }:

{
  #############################################################################
  # Home Manager Basic Configuration
  #############################################################################

  # User identity configuration
  home.username = "tom";
  home.homeDirectory = "/home/tom";

  # Let Home Manager install and manage itself
  programs.home-manager.enable = true;

  # Set Home Manager compatibility version
  home.stateVersion = "24.11";

  # Environment variables
  home.sessionVariables = {
    TERMINAL = "ghostty";
  };

  # Desktop entries - both hiding entries and adding new ones
  xdg.desktopEntries = {
    # Hide specific desktop entries
    bottom = {
      name = "Bottom";
      exec = "btm";
      terminal = true;
      categories = [ "System" "Monitor" ];
      noDisplay = true;
    };
    micro = {
      name = "Micro";
      exec = "micro";
      terminal = true;
      categories = [ "Development" "TextEditor" ];
      noDisplay = true;
    };

    # Add Claude Desktop entry
    claude-desktop = {
      name = "Claude Desktop";
      exec = "claude-desktop";
      icon = "claude-desktop"; # If an icon exists in the system
      comment = "Claude AI Desktop Application";
      categories = [ "Development" "Utility" "X-AI" ];
      terminal = false;
    };
  };

  #############################################################################
  # Package Management
  #############################################################################

  home.packages = with pkgs; [
    # Browsers and Personal Tools
    bitwarden-desktop
    google-chrome
    todoist-electron

    # Communication and Media
    deckmaster
    discord
    spotify
    zoom-us

    # Development Tools
    gh
    ghostty
    nil # Nix Language Server for VSCode

    # Modern Unix Tools
    bat # Modern cat replacement
    eza # Modern ls replacement
    fd # Modern find replacement
    ripgrep # Modern grep replacement
    zoxide # Smart cd command
    duf # Better disk usage utility
    bottom # Modern system monitor
    jq # JSON processor
    difftastic # Modern diff tool
    fzf # Fuzzy finder
    lazygit # Terminal UI for git
    micro # Simple text editor
    tldr # Simplified man pages with examples
    tmux # Terminal multiplexer
    fastfetch # System information tool
    cyme # Modern mail client
    dogdns # DNS client
    speedtest-go # Internet speed test
    pciutils # PCI utilities

    # Unstable Channel Packages
    unstable.claude-code

    # GNOME Extensions
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.vitals # System monitoring in GNOME panel

    # Networking
    tailscale # Zero-config VPN (service enabled in configuration.nix)
    bitwarden-cli # Bitwarden CLI client
    girouette # Network monitoring
  ];

  #############################################################################
  # Shell and Terminal Configuration
  #############################################################################

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      # NixOS rebuild aliases
      nixos-rebuild-flake = "sudo nixos-rebuild switch --flake ~/.nixos-config#$(hostname)";
      nrs = "sudo nixos-rebuild switch --flake ~/.nixos-config#$(hostname)";
      nrb = "sudo nixos-rebuild build --flake ~/.nixos-config#$(hostname)";
      nrt = "sudo nixos-rebuild test --flake ~/.nixos-config#$(hostname)";

      # Modern Unix tool aliases
      cat = "bat --paging=never";
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      find = "fd";
      grep = "rg";
      df = "duf";
      top = "btm";
      du = "duf";
    };
    initExtra = ''
      eval "$(starship init bash)"
      # zoxide must be initialized at the end of bash config
      eval "$(zoxide init bash)"
    '';
  };

  # Starship prompt
  programs.starship = {
    enable = true;
    settings = {
      scan_timeout = 10;
      command_timeout = 1000;
      add_newline = false;

      # Enhanced single line prompt with additional modules
      format = "$username$hostname$directory$custom$git_branch$git_status$python$nodejs$rust$nix_shell$memory_usage$battery$cmd_duration$time$character";

      username = {
        format = "[$user]($style) ";
        style_user = "#d9e2f7 bold";
        show_always = false;
      };

      hostname = {
        format = "[@$hostname]($style) ";
        style = "#9aa3b8 bold";
        ssh_only = true;
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "#d9e2f7 bold";
        format = "[$path]($style) ";
        home_symbol = "🏠";
        read_only = " 🔒";
      };

      character = {
        success_symbol = "[❯](#9aa3b8 bold)";
        error_symbol = "[❯](#cc5216 bold)";
        vimcmd_symbol = "[❮](#9aa3b8 bold)";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = "󰘬 ";
        style = "#d9e2f7 bold";
      };

      git_status = {
        format = "[$all_status$ahead_behind]($style)";
        style = "#cc5216 bold";
        conflicted = "≠";
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

      nix_shell = {
        format = "[❄️ $state( \($name\))]($style) ";
        style = "#9aa3b8 bold";
      };

      cmd_duration = {
        format = "took [$duration]($style) ";
        style = "#cc5216";
        min_time = 2000;
      };

      # Memory usage - shows current RAM usage
      memory_usage = {
        format = "$symbol[$ram_pct]($style) ";
        symbol = "🧠 ";
        style = "#9aa3b8";
        threshold = 75;
        disabled = false;
      };

      # Battery - only shows when charging or below 100%
      battery = {
        format = "[$symbol$percentage]($style) ";
        full_symbol = "🔋";
        charging_symbol = "⚡";
        discharging_symbol = "🔋";
        empty_symbol = "💀";
        display = [
          { threshold = 15; style = "#cc5216 bold"; }
          { threshold = 30; style = "#cc5216"; }
          { threshold = 100; style = "#9aa3b8"; }
        ];
        disabled = false;
      };

      # Time module
      time = {
        format = "🕙 [$time]($style) ";
        style = "#9aa3b8";
        disabled = false;
        time_format = "%I:%M%p"; # 12-hour format with AM/PM
      };

      # Custom indicators for specific contexts
      custom = {
        # Show special indicator when in the NixOS config directory
        nixos_config = {
          when = "test -d $HOME/.nixos-config";
          format = "[󱄅 NixOS Config]($style) ";
          style = "#9aa3b8 bold";
        };
        # Indicators for file extensions
        nix_files = {
          when = "test -n \"$(find . -maxdepth 1 -name '*.nix' -print -quit)\"";
          format = "[❄️ Nix]($style) ";
          style = "#9aa3b8 bold";
          disabled = false;
        };
        yaml_files = {
          when = "test -n \"$(find . -maxdepth 1 \\( -name '*.yml' -o -name '*.yaml' \\) -print -quit)\"";
          format = "[📄 YAML]($style) ";
          style = "#d9e2f7 bold";
          disabled = false;
        };
      };

      # Language version modules
      python = {
        format = "[$symbol$pyenv_prefix($version )($virtualenv )]($style)";
        symbol = "🐍 ";
        style = "#9aa3b8";
        detect_extensions = [ "py" ];
      };

      nodejs = {
        format = "[$symbol($version )]($style)";
        symbol = "⬢ ";
        style = "#9aa3b8";
        detect_extensions = [ "js" "jsx" "ts" "tsx" ];
      };

      rust = {
        format = "[$symbol($version )]($style)";
        symbol = "🦀 ";
        style = "#cc5216";
        detect_extensions = [ "rs" ];
      };

      # Completely disable line_break module
      line_break = {
        disabled = true;
      };
    };
  };

  # Modern Unix tool configurations
  programs.bat = {
    enable = true;
    config = {
      theme = "ansi";
      style = "plain";
    };
  };

  programs.eza = {
    enable = true;
    enableBashIntegration = false; # We set our own aliases above
    extraOptions = [
      "--group-directories-first"
      "--header"
    ];
    git = true;
    icons = "auto";
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];
  };

  # FZF - Command-line fuzzy finder
  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
  };

  # Tmux - Terminal multiplexer
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    terminal = "screen-256color";
    extraConfig = ''
      # Improve colors
      set -g default-terminal "screen-256color"
      set -ga terminal-overrides ",*256col*:Tc"

      # Set new panes to open in current directory
      bind c new-window -c "#{pane_current_path}"
      bind '"' split-window -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
    '';
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--smart-case"
      "--max-columns=150"
      "--max-columns-preview"
    ];
  };

  # Ghostty terminal emulator
  programs.ghostty = {
    enable = true;
    settings = {
      # Font settings
      "font-family" = "FiraCode Nerd Font";
      "font-size" = "12";
      "font-feature" = [
        "liga"
        "calt"
        "ss01"
        "ss02"
        "ss03"
        "ss04"
        "ss05"
      ];

      # Window settings
      "window-padding-x" = "10";
      "window-padding-y" = "10";
      "window-theme" = "dark";
      "cursor-style" = "block";
      "cursor-style-blink" = "true";

      # UI preferences
      "confirm-close-surface" = "false";
      "mouse-hide-while-typing" = "true";
      "shell-integration-features" = "no-cursor";
    };
  };

  #############################################################################
  # Development Tools Configuration
  #############################################################################

  # Git
  programs.git = {
    enable = true;
    userName = "Tom Cassady";
    userEmail = "heytcass@gmail.com";
    # Additional git configuration can go here
  };

  # VSCode
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        # Nix extensions
        arrterian.nix-env-selector
        bbenoist.nix
        jnoortheen.nix-ide

        # General useful extensions
        esbenp.prettier-vscode

        # YAML extensions
        redhat.vscode-yaml

        # Python extensions
        ms-python.python

        # Markdown extensions
        yzhang.markdown-all-in-one
        davidanson.vscode-markdownlint
        bierner.markdown-preview-github-styles
        bierner.markdown-emoji
      ];

      userSettings = {
        # Editor appearance
        "editor.fontFamily" = "FiraCode Nerd Font";
        "editor.fontSize" = 13;
        "editor.fontLigatures" = true;
        "editor.renderWhitespace" = "boundary";
        "editor.rulers" = [ 80 120 ];
        "editor.wordWrap" = "off";
        "files.trimTrailingWhitespace" = true;
        "workbench.colorTheme" = "Default Dark+";

        # Nix settings
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";

        # YAML settings
        "[yaml]" = {
          "editor.autoIndent" = "keep";
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
        };
        "yaml.format.enable" = true;
        "yaml.validate" = true;

        # Markdown settings
        "[markdown]" = {
          "editor.defaultFormatter" = "yzhang.markdown-all-in-one";
          "editor.formatOnSave" = true;
          "editor.wordWrap" = "on";
          "editor.renderWhitespace" = "all";
          "editor.acceptSuggestionOnEnter" = "off";
        };
        "markdown.extension.toc.updateOnSave" = true;
        "markdown.extension.preview.autoShowPreviewToSide" = false;
        "markdownlint.config" = {
          "MD024" = false; # Allow duplicate headings
          "MD033" = false; # Allow inline HTML
        };
      };
    };
  };

  # Hyprland configuration (conditional - will be enabled only on transporter)
  wayland.windowManager.hyprland = {
    # Will be enabled conditionally in the host-specific configuration
    enable = lib.mkDefault false;

    # Use the Hyprland package from nixpkgs
    package = pkgs.hyprland;

    # System integration
    systemd.enable = true;
    xwayland.enable = true;

    # Hyprland configuration
    settings = {
      # Monitor configuration
      monitor = [
        "eDP-1,preferred,auto,1" # Laptop built-in display
      ];

      # Input configuration
      input = {
        kb_layout = "us";
        kb_variant = "colemak";
        follow_mouse = 1;
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      # General settings
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = "rgba(33ccffee)";
        "col.inactive_border" = "rgba(595959aa)";
        layout = "dwindle";
      };

      # Decoration settings
      decoration = {
        rounding = 5;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = true;
        shadow_range = 4;
        shadow_render_power = 3;
      };

      # Animation settings
      animations = {
        enabled = true;
        bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
        animation = [
          "windows, 1, 7, myBezier"
          "windowsOut, 1, 7, default, popin 80%"
          "border, 1, 10, default"
          "fade, 1, 7, default"
          "workspaces, 1, 6, default"
        ];
      };

      # Window layout settings
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # Miscellaneous
      misc = {
        force_default_wallpaper = 0;
      };

      # Window rules
      windowrulev2 = [
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-connection-editor)$"
        "float,title:^(btop)$"
      ];

      # Key bindings
      "$mod" = "SUPER";
      bind = [
        # Application launchers
        "$mod, Return, exec, ghostty"  # Terminal
        "$mod, D, exec, wofi --show drun"  # App launcher
        "$mod, Q, killactive,"  # Close window

        # Window management
        "$mod, V, togglefloating,"  # Toggle floating
        "$mod, J, layoutmsg, cyclenext"  # Cycle next window
        "$mod, K, layoutmsg, cycleprev"  # Cycle previous window
        "$mod, F, fullscreen, 0"  # Toggle fullscreen

        # Workspace switching
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        # Move window to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        # Screenshots
        ", Print, exec, grim -g \"$(slurp)\" - | wl-copy"  # Screenshot area to clipboard
        "SHIFT, Print, exec, grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y-%m-%d_%H-%M-%S).png"  # Screenshot area to file

        # Volume control
        ", XF86AudioRaiseVolume, exec, pamixer -i 5"
        ", XF86AudioLowerVolume, exec, pamixer -d 5"
        ", XF86AudioMute, exec, pamixer -t"
      ];

      # Mouse bindings
      bindm = [
        "$mod, mouse:272, movewindow"  # Move windows with mouse
        "$mod, mouse:273, resizewindow"  # Resize windows with mouse
      ];

      # Startup applications
      exec-once = [
        "waybar"  # Status bar
        "nm-applet --indicator"  # Network manager
        "swww init"  # Wallpaper daemon
      ];
    };
  };

  # Waybar configuration for Hyprland
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    style = ''
      * {
        font-family: "FiraCode Nerd Font";
        font-size: 13px;
      }

      window#waybar {
        background-color: rgba(29, 29, 29, 0.8);
        color: #c0bfbc;
        transition-property: background-color;
        transition-duration: .5s;
      }

      #workspaces button {
        padding: 0 5px;
        background-color: transparent;
        color: #c0bfbc;
        border-bottom: 3px solid transparent;
      }

      #workspaces button.active {
        background-color: #3584e4;
        color: #ffffff;
        border-bottom: 3px solid #ffffff;
      }

      #clock,
      #battery,
      #cpu,
      #memory,
      #disk,
      #temperature,
      #network,
      #pulseaudio,
      #tray,
      #mode {
        padding: 0 10px;
        margin: 0 4px;
      }

      #battery.charging {
        color: #57e389;
      }

      #battery.warning:not(.charging) {
        color: #f66151;
      }
    '';

    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        height = 30;

        modules-left = ["hyprland/workspaces"];
        modules-center = ["hyprland/window"];
        modules-right = ["pulseaudio" "network" "cpu" "memory" "battery" "clock" "tray"];

        "hyprland/workspaces" = {
          format = "{name}";
          "on-click" = "activate";
        };

        "clock" = {
          "tooltip-format" = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
          "format-alt" = "{:%Y-%m-%d}";
        };

        "battery" = {
          "states" = {
            "good" = 95;
            "warning" = 30;
            "critical" = 15;
          };
          "format" = "{capacity}% {icon}";
          "format-charging" = "{capacity}% ";
          "format-plugged" = "{capacity}% ";
          "format-icons" = [ "" "" "" "" "" ];
        };

        "network" = {
          "format-wifi" = "{essid} ({signalStrength}%) ";
          "format-ethernet" = "{ipaddr}/{cidr} ";
          "tooltip-format" = "{ifname} via {gwaddr} ";
          "format-linked" = "{ifname} (No IP) ";
          "format-disconnected" = "Disconnected ⚠";
          "format-alt" = "{ifname}: {ipaddr}/{cidr}";
        };

        "pulseaudio" = {
          "format" = "{volume}% {icon} {format_source}";
          "format-bluetooth" = "{volume}% {icon} {format_source}";
          "format-bluetooth-muted" = " {icon} {format_source}";
          "format-muted" = " {format_source}";
          "format-source" = "{volume}% ";
          "format-source-muted" = "";
          "format-icons" = {
            "headphone" = "";
            "hands-free" = "";
            "headset" = "";
            "phone" = "";
            "portable" = "";
            "car" = "";
            "default" = [ "" "" "" ];
          };
          "on-click" = "pavucontrol";
        };

        "cpu" = {
          "format" = "{usage}% ";
          "tooltip" = false;
        };

        "memory" = {
          "format" = "{}% ";
        };
      };
    };
  };

  # Other Hyprland-related programs
  programs.wofi = {
    enable = lib.mkDefault false;  # Will be enabled conditionally
    style = ''
      window {
        margin: 0px;
        background-color: #1d1d1d;
        border-radius: 10px;
      }

      #input {
        margin: 5px;
        border: none;
        background-color: #2d2d2d;
        color: #c0bfbc;
      }

      #outer-box {
        margin: 5px;
        border: none;
      }

      #scroll {
        margin: 5px;
        border: none;
      }

      #text {
        margin: 5px;
        color: #c0bfbc;
      }

      #entry:selected {
        background-color: #3584e4;
        border-radius: 5px;
      }

      #entry:selected * {
        color: #ffffff;
      }
    '';
  };
}