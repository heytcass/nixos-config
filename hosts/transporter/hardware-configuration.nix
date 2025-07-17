# Hardware configuration for Dell Latitude 7280
# Enhanced configuration based on common Dell Latitude 7280 specifications
# Note: For optimal results, replace with actual hardware scan using:
# sudo nixos-generate-config --show-hardware-config

{
  config,
  lib,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Dell Latitude 7280 hardware configuration
  boot = {
    initrd = {
      availableKernelModules = [
        "xhci_pci"
        "ahci"
        "usb_storage"
        "sd_mod"
        "rtsx_pci_sdmmc"
        "nvme"       # Added for potential NVMe support
        "usbhid"     # Added for USB HID devices
        "i2c_hid"    # Added for I2C HID devices
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
    
    # Dell-specific optimizations
    kernelParams = [
      "intel_iommu=off"  # Moved from host config for better organization
      "i915.enable_psr=0"  # Disable PSR for better display stability
    ];
  };

  # Filesystem configuration handled by disko - do not define fileSystems here
  # swapDevices handled by disko swapfile

  # Hardware-specific optimizations
  hardware = {
    # Enable Intel microcode updates
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    
    # Enable firmware updates
    enableRedistributableFirmware = lib.mkDefault true;
    
    # Dell-specific hardware support
    enableAllFirmware = lib.mkDefault true;
  };

  # Network configuration
  networking.useDHCP = lib.mkDefault true;

  # Power management optimizations for laptop
  powerManagement = {
    enable = lib.mkDefault true;
    cpuFreqGovernor = lib.mkDefault "powersave";
  };

  # Platform specification
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
