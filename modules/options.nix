# NixOS options definitions for mySystem configuration
# Replaces shared.nix with proper typed options
{ lib, pkgs, ... }:

with lib;

{
  options.mySystem = {
    # User configuration options
    user = {
      name = mkOption {
        type = types.str;
        default = "tom";
        description = "Primary user name";
      };
      
      fullName = mkOption {
        type = types.str;
        default = "Tom Cassady";
        description = "User's full name";
      };
      
      email = mkOption {
        type = types.str;
        default = "heytcass@gmail.com";
        description = "User's email address";
      };
      
      shell = mkOption {
        type = types.package;
        default = pkgs.fish;
        description = "User's default shell";
      };
      
      groups = mkOption {
        type = types.listOf types.str;
        default = [ "networkmanager" "wheel" "podman" ];
        description = "Additional groups for the user";
      };
    };

    # Hardware configuration options
    hardware = {
      hostname = mkOption {
        type = types.str;
        default = "gti";
        description = "System hostname";
      };
      
      timezone = mkOption {
        type = types.str;
        default = "America/Detroit";
        description = "System timezone";
      };
      
      locale = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
        description = "System locale";
      };
      
      keyboardLayout = mkOption {
        type = types.str;
        default = "us";
        description = "Keyboard layout";
      };
      
      keyboardVariant = mkOption {
        type = types.str;
        default = "colemak";
        description = "Keyboard variant";
      };
    };

    # Performance tuning options
    performance = {
      swapiness = mkOption {
        type = types.int;
        default = 10;
        description = "VM swappiness value (0-100)";
      };
      
      cachePressure = mkOption {
        type = types.int;
        default = 50;
        description = "VFS cache pressure value";
      };
      
      dirtyRatio = mkOption {
        type = types.int;
        default = 15;
        description = "Dirty memory ratio percentage";
      };
      
      dirtyBackgroundRatio = mkOption {
        type = types.int;
        default = 5;
        description = "Dirty background ratio percentage";
      };
      
      zramPercent = mkOption {
        type = types.int;
        default = 50;
        description = "ZRAM size as percentage of RAM";
      };
      
      zramAlgorithm = mkOption {
        type = types.str;
        default = "zstd";
        description = "ZRAM compression algorithm";
      };
      
      cpuArchitecture = mkOption {
        type = types.str;
        default = "skylake";
        description = "CPU architecture for GCC optimization";
      };
      
      cpuTune = mkOption {
        type = types.str;
        default = "skylake";
        description = "CPU tuning target";
      };
      
      maxMapCount = mkOption {
        type = types.int;
        default = 262144;
        description = "Maximum memory map areas";
      };
      
      mmapMinAddr = mkOption {
        type = types.int;
        default = 65536;
        description = "Minimum mmap address for security";
      };
      
      overcommitMemory = mkOption {
        type = types.int;
        default = 1;
        description = "Memory overcommit handling (0=heuristic, 1=always, 2=never)";
      };
      
      overcommitRatio = mkOption {
        type = types.int;
        default = 50;
        description = "Memory overcommit ratio percentage";
      };
    };

    # Security configuration options
    security = {
      journalMaxSize = mkOption {
        type = types.str;
        default = "100M";
        description = "Maximum journal size";
      };
      
      runtimeMaxSize = mkOption {
        type = types.str;
        default = "50M";
        description = "Maximum runtime journal size";
      };
      
      gcRetentionDays = mkOption {
        type = types.str;
        default = "14d";
        description = "Garbage collection retention period";
      };
    };

    # Secrets management structure options
    secrets = {
      business = mkOption {
        type = types.attrs;
        default = {
          owner = "tom";
          group = "wheel";
          mode = "0400";
        };
        description = "Business/client work secrets configuration";
      };
      
      development = mkOption {
        type = types.attrs;
        default = {
          owner = "tom";
          group = "wheel";
          mode = "0400";
        };
        description = "Development and API secrets configuration";
      };
      
      system = mkOption {
        type = types.attrs;
        default = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
        description = "System-wide services secrets configuration";
      };
    };

    # Kernel parameters and flags
    intelFlags = mkOption {
      type = types.listOf types.str;
      default = [
        "i915.fastboot=1"
        "i915.enable_psr=1"
        "i915.enable_fbc=1"
        "i915.enable_guc=2"
        "i915.enable_dc=2"
      ];
      description = "Intel graphics optimization kernel parameters";
    };

    perfKernelParams = mkOption {
      type = types.listOf types.str;
      default = [
        "mitigations=auto"
        "nowatchdog"
        "intel_iommu=on"
        "iommu=pt"
        "quiet"
        "splash"
      ];
      description = "Performance-oriented kernel parameters";
    };

    # Shell aliases and abbreviations
    modernAliases = mkOption {
      type = types.attrsOf types.str;
      default = {
        ls = "eza --icons --git";
        ll = "eza --icons --git -l";
        la = "eza --icons --git -la";
        tree = "eza --icons --git --tree";
        find = "fd";
        grep = "rg";
        cat = "bat";
        top = "btm";
        ps = "procs";
        du = "dust";
        cd = "z";
        rebuild = "sudo nixos-rebuild switch --flake ~/.nixos#gti";
        nixos = "cd ~/.nixos";
        projects = "cd ~/projects";
        git-no-sign = "git -c commit.gpgsign=false";
      };
      description = "Modern CLI tool aliases";
    };

    gitAbbrs = mkOption {
      type = types.attrsOf types.str;
      default = {
        g = "git";
        gst = "git status";
        gaa = "git add --all";
        gcmsg = "git commit -m";
        gco = "git checkout";
        gb = "git branch";
        gd = "git diff";
        glog = "git log --oneline --graph --decorate";
      };
      description = "Git command abbreviations";
    };

    systemAbbrs = mkOption {
      type = types.attrsOf types.str;
      default = {
        rb = "rebuild";
        up = "update";
        ".." = "cd ..";
        "..." = "cd ../..";
      };
      description = "System management abbreviations";
    };
  };
}