{ config, pkgs, lib, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
  
  # TLP power management settings
  tlpSettings = {
    # CPU performance profiles
    CPU_SCALING_GOVERNOR_ON_AC = "performance";
    CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
    CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
    CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";
    
    # Intel CPU performance bounds
    CPU_MIN_PERF_ON_AC = 0;
    CPU_MAX_PERF_ON_AC = 100;
    CPU_MIN_PERF_ON_BAT = 0;
    CPU_MAX_PERF_ON_BAT = 50;
    
    # Platform profiles
    PLATFORM_PROFILE_ON_AC = "performance";
    PLATFORM_PROFILE_ON_BAT = "low-power";
    
    # Turbo boost configuration
    CPU_BOOST_ON_AC = 1;
    CPU_BOOST_ON_BAT = 0;
    CPU_HWP_DYN_BOOST_ON_AC = 1;
    CPU_HWP_DYN_BOOST_ON_BAT = 0;
    
    # Network power management
    WIFI_PWR_ON_AC = "off";
    WIFI_PWR_ON_BAT = "on";
    
    # PCIe power states
    PCIE_ASPM_ON_AC = "default";
    PCIE_ASPM_ON_BAT = "powersupersave";
    
    # Intel GPU frequency management
    INTEL_GPU_MIN_FREQ_ON_AC = 300;
    INTEL_GPU_MIN_FREQ_ON_BAT = 300;
    INTEL_GPU_MAX_FREQ_ON_AC = 1150;
    INTEL_GPU_MAX_FREQ_ON_BAT = 800;
    INTEL_GPU_BOOST_FREQ_ON_AC = 1150;
    INTEL_GPU_BOOST_FREQ_ON_BAT = 800;
    
    # USB power management
    USB_AUTOSUSPEND = 1;
    USB_EXCLUDE_AUDIO = 1;
    USB_EXCLUDE_BTUSB = 1;
    USB_EXCLUDE_PRINTER = 1;
    
    # Storage power management
    DISK_IDLE_SECS_ON_AC = 0;
    DISK_IDLE_SECS_ON_BAT = 2;
    MAX_LOST_WORK_SECS_ON_AC = 15;
    MAX_LOST_WORK_SECS_ON_BAT = 60;
  };
  
  # Storage I/O scheduler optimization rules
  storageOptimization = ''
    # NVMe SSD: disable scheduler (none) - only for main device, not partitions
    ACTION=="add|change", KERNEL=="nvme[0-9]n[0-9]", ATTR{queue/scheduler}="none"
    # SATA SSD: use mq-deadline scheduler
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';
in
{
  services = {
    # Disable conflicting power management
    power-profiles-daemon.enable = false;
    
    # Advanced power management with TLP
    tlp = {
      enable = true;
      settings = tlpSettings;
    };
    
    # Thermal management (defined in hardware.nix to avoid duplication)
    # thermald.enable = true;  # Removed - handled in hardware.nix
  };

  # Storage performance optimization
  services.udev.extraRules = storageOptimization;
}