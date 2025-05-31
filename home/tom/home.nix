{
  pkgs,
  config,
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
  ];

  # Dotfiles (currently managed through GUI/sync)
  home.file = {};

  # Services
  services.ssh-agent.enable = true;

  # Environment variables
  home.sessionVariables = {};

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
    };
  };
}