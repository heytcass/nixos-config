{ config, pkgs, lib, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
in
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
        intel-compute-runtime
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
    cpuFreqGovernor = "powersave";
  };

  # Essential hardware services
  services = {
    thermald.enable = true;     # Intel thermal management
    udisks2.enable = true;      # Auto-mount USB devices
    fstrim.enable = true;       # SSD optimization
    fwupd.enable = true;        # Firmware updates
  };

  # Memory optimization with zram
  zramSwap = {
    enable = true;
    algorithm = shared.performance.zramAlgorithm;
    memoryPercent = shared.performance.zramPercent;
  };
}