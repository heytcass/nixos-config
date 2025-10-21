{ config, pkgs, pkgs-latest, lib, ... }:

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
    redhat.vscode-yaml # YAML syntax & validation
    # ms-python.python                # Python support - temporarily disabled due to pygls build issue
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
    packages = (with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.jetbrains-mono
      discord
      anytype
    ]) ++ [
      pkgs-latest.multiviewer-for-f1
    ];
  };

  # Enable Home Manager
  programs.home-manager.enable = true;
  fonts.fontconfig.enable = true;

  # XDG configuration
  xdg = {
    enable = true;

    # Hide terminal applications from app launcher
    desktopEntries = {
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

    # Autostart deckmaster for Stream Deck
    configFile."autostart/deckmaster.desktop".text = ''
      [Desktop Entry]
      Name=Deckmaster
      Comment=Stream Deck Controller
      Type=Application
      Exec=${pkgs.deckmaster}/bin/deckmaster -deck ${config.home.homeDirectory}/.config/deckmaster/simple.deck
      Categories=
      Terminal=false
      NoDisplay=true
      StartupNotify=false
    '';
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
      settings = gitConfig // {
        user = {
          name = "Tom Cassady";
          email = "heytcass@gmail.com";
        };
      };
    };

    # Delta (git diff pager)
    delta = {
      enable = true;
      enableGitIntegration = true;
      options = deltaOptions;
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
      enableDefaultConfig = false;  # Disable deprecated default values
      matchBlocks = {
        "*" = {
          addKeysToAgent = "yes";  # Moved from top-level
          extraOptions = {
            IdentityAgent = "/run/user/1000/yubikey-agent/yubikey-agent.sock";
          };
        };
        "github.com" = {
          hostname = "github.com";
          user = "git";
          identitiesOnly = true;
        };
      };
    };

    # VS Code IDE
    vscode = {
      enable = true;
      profiles.default = {
        extensions = vscodeExtensions;
        userSettings = vscodeSettings;
      };
    };

    # OBS Studio for professional video calls
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs # Wayland screen capture support
        obs-pipewire-audio-capture # PipeWire audio integration
        obs-vaapi # Hardware video encoding (Intel)
      ];
    };

    # Fastfetch system information display
    fastfetch = {
      enable = true;
      settings = {
        "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
        logo = {
          padding = {
            top = 5;
            right = 6;
          };
        };
        modules = [
          "break"
          {
            type = "custom";
            format = "┌──────────────────────Hardware──────────────────────┐";
          }
          {
            type = "host";
            key = " PC";
            keyColor = "green";
          }
          {
            type = "cpu";
            key = "│ ├";
            showPeCoreCount = true;
            keyColor = "green";
          }
          {
            type = "gpu";
            key = "│ ├";
            detectionMethod = "pci";
            keyColor = "green";
          }
          {
            type = "display";
            key = "│ ├󱄄";
            keyColor = "green";
          }
          {
            type = "disk";
            key = "│ ├󰋊";
            keyColor = "green";
          }
          {
            type = "memory";
            key = "│ ├";
            keyColor = "green";
          }
          {
            type = "swap";
            key = "└ └󰓡 ";
            keyColor = "green";
          }
          {
            type = "custom";
            format = "└────────────────────────────────────────────────────┘";
          }
          "break"
          {
            type = "custom";
            format = "┌──────────────────────Software──────────────────────┐";
          }
          {
            type = "os";
            key = "❄ OS";
            keyColor = "yellow";
          }
          {
            type = "kernel";
            key = "│ ├";
            keyColor = "yellow";
          }
          {
            type = "packages";
            key = "│ ├󰏖";
            keyColor = "yellow";
          }
          {
            type = "shell";
            key = "└ └";
            keyColor = "yellow";
          }
          "break"
          {
            type = "de";
            key = " DE";
            keyColor = "blue";
          }
          {
            type = "wm";
            key = "│ ├";
            keyColor = "blue";
          }
          {
            type = "wmtheme";
            key = "│ ├󰉼";
            keyColor = "blue";
          }
          {
            type = "icons";
            key = "│ ├󰀻";
            keyColor = "blue";
          }
          {
            type = "cursor";
            key = "│ ├";
            keyColor = "blue";
          }
          {
            type = "terminalfont";
            key = "│ ├";
            keyColor = "blue";
          }
          {
            type = "terminal";
            key = "└ └";
            keyColor = "blue";
          }
          {
            type = "custom";
            format = "└────────────────────────────────────────────────────┘";
          }
          "break"
          {
            type = "custom";
            format = "┌────────────────────Uptime / Age────────────────────┐";
          }
          {
            type = "command";
            key = "  OS Age ";
            keyColor = "magenta";
            text = "birth_install=$(stat -c %W /); current=$(date +%s); time_progression=$((current - birth_install)); days_difference=$((time_progression / 86400)); echo $days_difference days";
          }
          {
            type = "uptime";
            key = "  Uptime ";
            keyColor = "magenta";
          }
          {
            type = "custom";
            format = "└────────────────────────────────────────────────────┘";
          }
          "break"
        ];
      };
    };
  };

  # User services configuration
  services = {
    # EasyEffects professional audio processing
    easyeffects = {
      enable = true;
      preset = "Professional Calls Input";

      # Declarative preset configuration  
      extraPresets = {
        "Professional Calls Input" = {
          input = {
            blocklist = [ ];

            # Professional effects chain: Gate -> Compressor -> Filter -> Limiter
            gate = {
              bypass = false;
              attack = 20.0;
              release = 100.0;
              threshold = -30.0;
              ratio = 2.0;
              reduction = -24.0;
              makeup = 0.0;
              input-gain = 0.0;
              output-gain = 0.0;
            };

            compressor = {
              bypass = false;
              attack = 20.0;
              release = 100.0;
              threshold = -18.0;
              ratio = 4.0;
              makeup = 0.0;
              input-gain = 0.0;
              output-gain = 0.0;
              mode = "Downward";
            };

            filter = {
              bypass = false;
              frequency = 10000.0;
              input-gain = 0.0;
              output-gain = 0.0;
              type = "Band-Pass";
              width = 4.0;
            };

            limiter = {
              bypass = false;
              attack = 5.0;
              release = 5.0;
              threshold = -3.0;
              input-gain = 0.0;
              output-gain = 0.0;
            };
          };

          output = {
            blocklist = [ ];
          };
        };
      };
    };
  };
}
