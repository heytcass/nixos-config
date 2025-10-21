{ config, pkgs, lib, ... }:
{
  hardware = {
    # Enable all hardware optimizations
    enableRedistributableFirmware = true;

    # Intel graphics with hardware acceleration
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        intel-media-driver
        intel-vaapi-driver
        vaapiVdpau
        libvdpau-va-gl
        # intel-compute-runtime # Commented out due to version conflicts
      ];
    };

    # Intel CPU optimizations
    cpu.intel.updateMicrocode = true;

    # Wireless connectivity
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
  };

  # System power management
  powerManagement = {
    enable = true;
  };

  # Kernel modules for hardware control
  boot.kernelModules = [ "i2c-dev" "uinput" ];

  # User groups for hardware access
  users.groups.uinput = {};

  # Essential hardware services
  services = {
    thermald.enable = true; # Intel thermal management
    udisks2.enable = true; # Auto-mount USB devices
    fstrim.enable = true; # SSD optimization
    fwupd.enable = true; # Firmware updates

    # Stream Deck udev configuration
    udev = {
      packages = with pkgs; [
        deckmaster # Stream Deck udev rules package (moved from security.nix to avoid duplication)
      ];

      extraRules = ''
        # Elgato Stream Deck - Grant access to uinput group
        SUBSYSTEM=="input", GROUP="input", MODE="0666"
        KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess", OPTIONS+="static_node=uinput", GROUP="uinput", MODE="0660"

        # Elgato Stream Deck USB devices
        SUBSYSTEM=="usb", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060|0063|006c|006d|0080|0090", TAG+="uaccess"

        # Elgato Stream Deck HID devices - this is what deckmaster actually uses
        KERNEL=="hidraw*", ATTRS{idVendor}=="0fd9", ATTRS{idProduct}=="0060|0063|006c|006d|0080|0090", TAG+="uaccess", GROUP="plugdev", MODE="0660"
      '';
    };
  };

  # Memory optimization with zram
  zramSwap = {
    enable = true;
    algorithm = config.mySystem.performance.zramAlgorithm;
    memoryPercent = config.mySystem.performance.zramPercent;
  };
}
