# Impermanence configuration - Stateless root filesystem
# Conservative approach preserving essential directories initially
{ config, lib, pkgs, ... }:

{
  # Enable impermanence
  environment.persistence."/persist" = {
    hideMounts = true;
    
    # System essential directories
    directories = [
      # NixOS system state
      "/etc/nixos"
      "/var/lib/nixos" 
      "/var/lib/systemd/coredump"
      
      # SSH and machine identity
      "/etc/ssh"
      "/etc/machine-id"
      
      # Hardware and firmware  
      "/var/lib/fwupd"
      "/var/lib/bluetooth"
      "/var/lib/alsa"
      
      # Secrets and security
      "/var/lib/sops-nix"
      "/etc/secureboot"
      
      # Development and containers
      "/var/lib/containers"
      "/var/lib/docker" # if using docker
      
      # Network configuration
      "/etc/NetworkManager/system-connections"
      
      # Conservative: Preserve logs initially for debugging
      "/var/log"
      
      # Conservative: Preserve some caches for performance
      "/var/cache/nix"
      
      # systemd journal
      "/var/lib/systemd/catalog"
      "/var/lib/systemd/backlight"
      "/var/lib/systemd/rfkill"
      
      # GNOME/Desktop state (user will appreciate not losing settings)
      "/var/lib/AccountsService"
    ];
    
    # Individual files that need persistence
    files = [
      "/etc/machine-id"
    ];
    
    # User data - complete preservation initially
    users.tom = {
      directories = [
        "Documents"
        "Downloads" 
        "Music"
        "Pictures"
        "Videos"
        "Desktop"
        "Projects"
        ".nixos"  # Our configuration!
        
        # Development
        ".ssh"
        ".gnupg"
        ".config"
        ".local"
        ".cache"  # Conservative: preserve user caches initially
        
        # Applications that store important data
        ".mozilla"  # Firefox profiles
        ".config/google-chrome"
        ".config/Code"  # VS Code settings
        ".config/Slack"
        ".config/obs-studio"
        
        # Shell and tools
        ".config/fish"
        ".local/share/fish"
        ".config/starship.toml"
      ];
      
      files = [
        ".bashrc"
        ".bash_history"
        # Fish shell history will be in .local/share/fish - covered by directories
      ];
    };
  };
  
  # Note: For impermanence to work, we need to:
  # 1. Create /persist directory on current root filesystem  
  # 2. Move important data to /persist
  # 3. Then reconfigure root as tmpfs
  # This configuration documents the target state but needs manual migration
  
  # Enable tmpfs root filesystem for impermanence
  fileSystems."/" = lib.mkForce {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=2G" "mode=755" ];
    neededForBoot = true;
  };
  
  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/0e306945-1bb5-4a94-a518-2d472628a272";
    fsType = "ext4";
    neededForBoot = true;
  };
  
  # Programs that may need special handling for impermanence
  # Note: programs.fuse.userMount doesn't exist in current NixOS version
  
  # Essential services that need early availability
  systemd.tmpfiles.rules = [
    # Ensure critical directories exist early in boot
    "d /persist/home 0755 root root -"
    "d /persist/home/tom 0755 tom users -"
    "d /persist/etc 0755 root root -"
    "d /persist/var 0755 root root -"
    "d /persist/var/lib 0755 root root -"
    "d /persist/var/log 0755 root root -"
  ];
}