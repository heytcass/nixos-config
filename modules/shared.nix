# Shared constants and variables to maintain DRY principles
{ lib, pkgs, ... }:

{
  # Define shared user information
  user = {
    name = "tom";
    fullName = "Tom Cassady";
    email = "heytcass@gmail.com";  # Update with actual email
    shell = pkgs.fish;
    groups = [ "networkmanager" "wheel" "podman" ];
  };

  # Hardware-specific constants
  hardware = {
    hostname = "gti";
    timezone = "America/Detroit";
    locale = "en_US.UTF-8";
    keyboardLayout = "us";
    keyboardVariant = "colemak";
  };

  # Performance tuning constants
  performance = {
    swapiness = 10;
    cachePressure = 50;
    dirtyRatio = 15;
    dirtyBackgroundRatio = 5;
    zramPercent = 50;
    zramAlgorithm = "zstd";
    
    # CPU-specific optimizations for i5-8250U (Kaby Lake R)
    # Note: GCC uses "skylake" for Kaby Lake since they share the same microarchitecture
    # Kaby Lake is essentially Skylake with minor improvements, so skylake is correct
    cpuArchitecture = "skylake";  # Correct for Kaby Lake (no separate kabylake option)
    cpuTune = "skylake";
    
    # Advanced memory management settings
    maxMapCount = 262144;          # For memory-intensive applications
    mmapMinAddr = 65536;           # Security: prevent null pointer dereference exploits
    overcommitMemory = 1;          # Always overcommit memory
    overcommitRatio = 50;          # Conservative memory overcommit
  };

  # Security constants
  security = {
    journalMaxSize = "100M";
    runtimeMaxSize = "50M";
    gcRetentionDays = "14d";
  };
  
  # Secrets structure constants
  secrets = {
    # Business/Client work secrets
    business = {
      owner = "tom";
      group = "wheel";
      mode = "0400";
    };
    
    # Development and API secrets
    development = {
      owner = "tom";
      group = "wheel";
      mode = "0400";
    };
    
    # System-wide services
    system = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  # Intel graphics optimization flags
  intelFlags = [
    "i915.fastboot=1"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "i915.enable_guc=2"
    "i915.enable_dc=2"
  ];

  # Performance kernel parameters
  perfKernelParams = [
    "mitigations=auto"    # Security: Enable CPU vulnerability mitigations with performance optimization
    "nowatchdog"
    "intel_iommu=on"
    "iommu=pt"
    "quiet"
    "splash"
  ];

  # Rust-based tool aliases
  modernAliases = {
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
    
    # System management
    rebuild = "sudo nixos-rebuild switch --flake ~/.nixos#gti";
    
    # Directory navigation
    nixos = "cd ~/.nixos";
    projects = "cd ~/projects";
    
    # Git without GPG signing (for Claude Code)
    git-no-sign = "git -c commit.gpgsign=false";
  };

  # Git abbreviations
  gitAbbrs = {
    g = "git";
    gst = "git status";
    gaa = "git add --all";
    gcmsg = "git commit -m";
    gco = "git checkout";
    gb = "git branch";
    gd = "git diff";
    glog = "git log --oneline --graph --decorate";
  };

  # System management shortcuts
  systemAbbrs = {
    rb = "rebuild";
    up = "update";
    ".." = "cd ..";
    "..." = "cd ../..";
  };
}
