{ pkgs, unstable, inputs, ... }:

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
  # This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes
  home.stateVersion = "24.11";

  # Environment variables
  home.sessionVariables = {
    TERMINAL = "ghostty";
  };
  
  # Hide specific desktop entries
  xdg.desktopEntries = {
    bottom = {
      name = "Bottom";
      exec = "btm";
      terminal = true;
      categories = [ "System" "Monitor" ];
      noDisplay = true;
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

    # Unstable Channel Packages
    unstable.claude-code

    # GNOME Extensions
    pkgs.gnomeExtensions.appindicator
    pkgs.gnomeExtensions.vitals # System monitoring in GNOME panel

    # Networking
    tailscale # Zero-config VPN (service enabled in configuration.nix)

    # Add any other user packages below
  ];

  #############################################################################
  # Shell and Terminal Configuration
  #############################################################################

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      # NixOS rebuild aliases
      nixos-rebuild-flake = "sudo nixos-rebuild switch --flake ~/.nixos-config#gti";
      nrs = "sudo nixos-rebuild switch --flake ~/.nixos-config#gti";
      nrb = "sudo nixos-rebuild build --flake ~/.nixos-config#gti";
      nrt = "sudo nixos-rebuild test --flake ~/.nixos-config#gti";

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
      add_newline = true;
      command_timeout = 1000;
      format = "$all";
      nix_shell = {
        format = "via [$symbol$state( \($name\))]($style) ";
        symbol = "❄️ ";
      };
    };
  };

  # Modern Unix tool configurations
  programs.bat = {
    enable = true;
    config = {
      theme = "Dracula";
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
    options = ["--cmd cd"];
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

      # Theme
      "theme" = "Adwaita Dark";
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
      };
    };
  };
}
