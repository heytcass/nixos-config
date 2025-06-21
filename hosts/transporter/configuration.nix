# Dell Latitude 7280 - Secondary laptop configuration  
# Host-specific settings for the transporter system

{
  config,
  pkgs,
  inputs,
  hostname,
  username,
  ...
}: {
  imports = [
    # Hardware configuration (auto-generated)
    ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = hostname;
  
  # Dell Latitude 7280 specific optimizations
  # Intel graphics and power management
  hardware.enableAllFirmware = true;
  hardware.cpu.intel.updateMicrocode = true;
  services.thermald.enable = true;
  services.power-profiles-daemon.enable = false; # Disabled for TLP
  
  # Kernel parameters for stability
  boot.kernelParams = [ "intel_iommu=off" ];
  
  # Btrfs maintenance and snapshots
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };

  # Automatic TRIM for SSD longevity
  services.fstrim.enable = true;

  # Laptop power optimization
  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      RUNTIME_PM_ON_AC = "on";
      RUNTIME_PM_ON_BAT = "auto";
    };
  };

  # Dell-specific hardware support
  boot.initrd.kernelModules = [ "i915" ];  # Intel graphics
  hardware.graphics.enable = true;
  services.libinput.enable = true;  # Touchpad
}