# Live ISO configuration
# Minimal NixOS installation and recovery environment

{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # NixOS minimal ISO module for smaller builds
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # ISO-specific configuration
  isoImage = {
    isoName = "nixos-tom-config.iso";
    volumeID = "NIXOS_TOM";
    makeEfiBootable = true;
    makeUsbBootable = true;
  };

  # ISO-specific services (desktop is handled by mixin system)
  services = {
    # SSH for remote access
    openssh = {
      enable = true;
      settings.PermitRootLogin = "yes";
    };
  };

  # Live environment specific packages (additional to mixin packages)
  environment.systemPackages = with pkgs; [
    # Hardware and installation tools
    smartmontools
    hdparm
    gparted
    parted
    ntfs3g

    # Archive tools
    unzip
    p7zip

    # System info
    neofetch
    lshw
  ];

  # ISO-specific overrides
  boot = {
    # Disable ZFS for Live ISO
    supportedFilesystems.zfs = lib.mkForce false;
    # Override boot configuration for ISO compatibility
    loader.timeout = lib.mkForce null; # Let ISO use default timeout
  };

  # Enable passwordless sudo for live environment
  security.sudo.wheelNeedsPassword = false;
}
