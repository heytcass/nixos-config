{ config, pkgs, lib, notion-mac-flake, claude-desktop-linux-flake, nix-output-monitor, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
  
  # Modern Rust-based utilities (oxidizr-inspired)
  rustTools = with pkgs; [
    eza ripgrep fd bat dust procs bottom zoxide fzf
    delta tokei hyperfine tealdeer mcfly broot xh bandwhich
  ];
  
  # File management and workflow tools
  fileManagementTools = with pkgs; [
    nnn          # Terminal file manager
    direnv       # Directory-specific environments
    tmux         # Terminal multiplexer
    btop         # Modern system monitor
  ];
  
  # Network and system monitoring
  networkTools = with pkgs; [
    iftop        # Network bandwidth monitor  
    nethogs      # Network usage by process
    iotop        # I/O monitoring
    lsof         # List open files
  ];
  
  # Essential user applications
  userApps = with pkgs; [
    bitwarden-cli bitwarden-desktop claude-code
    gh google-chrome podman vscode
    slack zoom-us morewaita-icon-theme
  ];
  
  # Professional communication and video tools
  communicationTools = with pkgs; [
    obs-studio              # Professional video recording and streaming
    obs-studio-plugins.wlrobs # Wayland screen capture for OBS
    easyeffects             # Real-time audio effects and enhancement
    helvum                  # GTK-based PipeWire patchbay (better for GNOME)
    v4l-utils              # Video4Linux utilities for camera control
  ];
  
  # YubiKey tools
  yubikeyTools = with pkgs; [
    yubikey-manager          # YubiKey configuration tool
    yubikey-agent           # SSH agent for YubiKey
    yubikey-touch-detector  # Visual touch feedback
    age-plugin-yubikey      # YubiKey plugin for age encryption
    yubico-piv-tool         # PIV smart card functionality
    gnupg                   # GPG for YubiKey OpenPGP
    pinentry-gtk2           # GUI for PIN entry
  ];
  
  # Custom flake packages
  customApps = [
    notion-mac-flake.packages.${pkgs.system}.default
    claude-desktop-linux-flake.packages.${pkgs.system}.default
    nix-output-monitor.packages.${pkgs.system}.default
  ];
  
  # FZF configuration for file finding
  fzfConfig = ''
    set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -x FZF_ALT_C_COMMAND 'fd --type d --hidden --follow --exclude .git'
  '';
  
  # Shell initialization
  shellInit = ''
    # Initialize modern command-line tools
    zoxide init fish | source
    mcfly init fish | source
    
    # Configure bat theme
    set -x BAT_THEME "GitHub"
    
    # GPG configuration for YubiKey
    set -x GPG_TTY (tty)
    
    # FZF file finder configuration
    ${fzfConfig}
  '';
  
  # Starship prompt configuration
  starshipConfig = {
    format = "$all$character";
    right_format = "$time";
    
    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
    };
    
    directory = {
      truncation_length = 3;
      fish_style_pwd_dir_length = 1;
    };
    
    git_branch.symbol = " ";
    
    time = {
      disabled = false;
      format = "[$time](dimmed white)";
    };
  };
in
{
  # Install modern command-line tools
  environment.systemPackages = rustTools ++ fileManagementTools ++ networkTools ++ userApps ++ communicationTools ++ yubikeyTools ++ customApps;


  # Configure Fish shell with modern tooling
  programs = {
    fish = {
      enable = true;
      shellAliases = shared.modernAliases;
      interactiveShellInit = shellInit;
    };
    
    # Modern shell prompt
    starship = {
      enable = true;
      settings = starshipConfig;
    };
    
    # Directory-specific environments
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    
    # Terminal multiplexer
    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      extraConfig = ''
        # Modern tmux configuration
        set -g mouse on
        set -g default-terminal "screen-256color"
        set -ag terminal-overrides ",xterm-256color:RGB"
      '';
    };
  };
}