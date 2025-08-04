{ config, pkgs, lib, ... }:

let
  # System management functions
  systemFunctions = {
    rebuild = "sudo nixos-rebuild switch --flake /home/tom/.nixos#gti";
    update = "sudo nixos-rebuild switch --upgrade --flake /home/tom/.nixos#gti";
    mkcd = "mkdir -p $argv[1]; and cd $argv[1]";
  };
  
  # Git workflow functions
  gitFunctions = {
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git pull";
  };
  
  # Combined shell abbreviations
  allAbbrs = {
    # System abbreviations
    rb = "rebuild";
    up = "update";
    ".." = "cd ..";
    "..." = "cd ../..";
    # Git abbreviations
    g = "git";
    gst = "git status";
    gaa = "git add --all";
    gcmsg = "git commit -m";
    gco = "git checkout";
    gb = "git branch";
    gd = "git diff";
    glog = "git log --oneline --graph --decorate";
    # Additional abbreviations
    ll = "eza -l --icons --git";
    la = "eza -la --icons --git";
  };
  
  # VS Code extensions
  vscodeExtensions = with pkgs.vscode-extensions; [
    # Remote & Container tools
    ms-vscode-remote.remote-containers
    ms-azuretools.vscode-docker
    
    # AI Assistance (helps with everything!)
    github.copilot
    github.copilot-chat
    
    # Themes & Icons
    pkief.material-icon-theme
    github.github-vscode-theme
    
    # Additional useful extensions
    redhat.vscode-yaml              # YAML syntax & validation
    ms-python.python                # Python support
  ];
  
  # VS Code user settings
  vscodeSettings = {
    "editor.fontFamily" = "'FiraCode Nerd Font', 'monospace'";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 14;
    "editor.minimap.enabled" = false;
    "workbench.colorTheme" = "Claude Theme";
    "workbench.iconTheme" = "material-icon-theme";
    "terminal.integrated.defaultProfile.linux" = "fish";
  };
  
  # Git configuration
  gitConfig = {
    init.defaultBranch = "main";
    pull.rebase = true;
    push.autoSetupRemote = true;
    core.editor = "code --wait";
    diff.tool = "vscode";
    merge.tool = "vscode";
    
    # GitHub CLI integration
    credential = {
      "https://github.com" = {
        helper = "!gh auth git-credential";
      };
      "https://gist.github.com" = {
        helper = "!gh auth git-credential";
      };
    };
    
    # GPG signing configuration
    commit.gpgsign = true;
    gpg.format = "openpgp";
    # The signing key ID is stored in sops but needs to be read as a value
    # For now, using the literal value until we set up proper secret reading
    user.signingkey = "34F011E3CF3B61A71571FCC9C01F5B8505294BED";
    
    # Git aliases for different use cases
    alias = {
      # For Claude Code - commits without GPG signing
      cc-commit = "commit --no-gpg-sign";
      cc-commit-msg = "!f() { git commit --no-gpg-sign -m \"$1\"; }; f";
    };
  };
  
  # Delta (git diff) configuration
  deltaOptions = {
    navigate = true;
    line-numbers = true;
    syntax-theme = "GitHub";
  };
in
{
  # Home Manager configuration
  home = {
    username = "tom";
    homeDirectory = "/home/tom";
    stateVersion = "25.05";
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
    ];
  };

  # Enable Home Manager
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;
  
  # Hide terminal applications from app launcher
  xdg.desktopEntries = {
    nnn = {
      name = "nnn";
      noDisplay = true;
    };
    btop = {
      name = "btop";
      noDisplay = true;
    };
    bottom = {
      name = "bottom";
      noDisplay = true;
    };
  };

  # sops-nix user configuration
  sops = {
    # User age key file
    age.keyFile = "/home/tom/.config/sops/age/keys.txt";
    
    # Default user secrets file
    defaultSopsFile = ./secrets/user-secrets.yaml;
    defaultSopsFormat = "yaml";
    
    # User secrets
    secrets = {
      # GPG signing key ID for Git commits
      "gpg/signing_key_id" = {
        mode = "0400";
      };
    };
  };

  programs = {
    # Git version control
    git = {
      enable = true;
      userName = "Tom Cassady";
      userEmail = "heytcass@gmail.com";
      extraConfig = gitConfig;
      delta = {
        enable = true;
        options = deltaOptions;
      };
    };

    # GPG configuration for YubiKey commit signing
    gpg = {
      enable = true;
      settings = {
        # YubiKey configuration
        use-agent = true;
      };
    };

    # Fish shell configuration
    fish = {
      enable = true;
      functions = systemFunctions // gitFunctions;
      shellAbbrs = allAbbrs;
    };

    # SSH configuration for YubiKey
    ssh = {
      enable = true;
      addKeysToAgent = "yes";
      extraConfig = ''
        # YubiKey SSH agent integration (commented out - enable after YubiKey setup)
        # IdentityAgent ~/.yubikey-agent.sock
        
        # Standard SSH config
        Host github.com
          HostName github.com
          User git
          IdentitiesOnly yes
      '';
    };

    # VS Code IDE
    vscode = {
      enable = true;
      profiles.default = {
        extensions = vscodeExtensions;
        userSettings = vscodeSettings;
      };
    };
  };
}