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

    # Unstable Channel Packages
    unstable.claude-code

    # GNOME Extensions
    pkgs.gnomeExtensions.appindicator

    # Add any other user packages below
  ];

  #############################################################################
  # Shell and Terminal Configuration
  #############################################################################

  # Bash configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      nixos-rebuild-flake = "sudo nixos-rebuild switch --flake ~/.nixos-config#gti";
    };
    initExtra = ''
      eval "$(starship init bash)"
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
