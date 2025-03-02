{ config, pkgs, unstable, inputs, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "tom";
  home.homeDirectory = "/home/tom";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # User packages that were in your configuration.nix
  home.packages = with pkgs; [
    google-chrome
    bitwarden-desktop
    discord
    nodejs
    gh
    ripgrep
    node2nix
    ghostty
    nil # Nix Language Server for VSCode
    # Add any other user packages you want here
  ] ++ [
    # Packages from unstable channel
    unstable.claude-code
  ] ++ [
    # GNOME extensions
    pkgs.gnomeExtensions.appindicator
  ];

  # Git configuration
  programs.git = {
    enable = true;
    userName = "Tom Cassady";
    userEmail = "heytcass@gmail.com";
    # Additional git configuration can go here
  };

  # Terminal configuration
  programs.bash = {
    enable = true;
    shellAliases = {
      nixos-rebuild-flake = "sudo nixos-rebuild switch --flake ~/.nixos-config#gti";
    };
    initExtra = ''
      eval "$(starship init bash)"
    '';
  };
  
  # Starship prompt configuration
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
  
  # Set Ghostty as default terminal
  home.sessionVariables = {
    TERMINAL = "ghostty";
  };

  # Ghostty terminal configuration with Adwaita Dark theme
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


  # VSCode configuration
  programs.vscode = {
    enable = true;
    profiles.default = {
      extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.system}.vscode-marketplace; [
        # Nix extensions
        jnoortheen.nix-ide
        arrterian.nix-env-selector
        bbenoist.nix
        
        # YAML extensions
        redhat.vscode-yaml
        
        # General useful extensions
        esbenp.prettier-vscode
      ];
      
      userSettings = {
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
        "yaml.format.enable" = true;
        "yaml.validate" = true;
        "[yaml]" = {
          "editor.insertSpaces" = true;
          "editor.tabSize" = 2;
          "editor.autoIndent" = "keep";
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  home.stateVersion = "24.11";
}
