# Hardware configuration for Dell Latitude 7280 (transporter)
# This replaces hardware-configuration.nix for the Latitude system

{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  # Typical Dell Latitude 7280 hardware modules
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sdhci_pci" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # NOTE: Actual filesystem configuration is handled by disko
  # These are placeholders that will be overridden by disko
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = [ "subvol=rootfs" "compress=zstd" "noatime" ];
  };

  fileSystems."/boot" = lib.mkDefault {
    device = "/dev/disk/by-label/ESP";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = lib.mkDefault [
    { device = "/dev/disk/by-label/swap"; }
  ];

  # Enables DHCP on each ethernet and wireless interface
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
