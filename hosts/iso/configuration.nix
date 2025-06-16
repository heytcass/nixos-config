{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    # Core system modules
    ../../modules/common/base.nix
    ../../modules/common/users.nix
    
    # NixOS ISO module
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
  ];

  # ISO-specific configuration
  isoImage = {
    isoName = "nixos-tom-config.iso";
    volumeID = "NIXOS_TOM";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # Networking
  networking = {
    hostName = "nixos-live";
    wireless.enable = false; # Use NetworkManager instead
  };

  # Services specific to live environment
  services = {
    # Enable X11 for GUI
    xserver = {
      enable = true;
      xkb = {
        layout = "us";
        variant = "colemak";
      };
    };

    # Display manager and desktop
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # SSH for remote access
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  # Live environment specific packages
  environment.systemPackages = with pkgs; [
    # Essential tools
    git
    vim
    wget
    curl
    htop
    tree
    
    # Network tools
    networkmanager
    wpa_supplicant
    
    # Hardware tools
    smartmontools
    hdparm
    
    # Partitioning and file systems
    gparted
    parted
    ntfs3g
    
    # Archive tools
    unzip
    p7zip
    
    # Text editors
    micro
    
    # System info
    neofetch
    lshw
    
    # Modern CLI tools (from your home manager config)
    bat
    eza
    fd
    ripgrep
    procs
    bottom
    gping
    dua
  ];

  # Enable fish shell system-wide
  programs.fish.enable = true;

  # Disable ZFS for Live ISO
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # Set default user password for live environment
  users.users.tom.password = "nixos";
  users.users.root.password = "nixos";

  # Enable passwordless sudo for tom user in live environment
  security.sudo.wheelNeedsPassword = false;

  # Override boot configuration for ISO compatibility
  boot.loader.timeout = lib.mkForce null; # Let ISO use default timeout

  # System state version
  system.stateVersion = "24.11";
}