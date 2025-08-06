{ config, pkgs, lib, ... }:
{
  boot = {
    # Boot loader configuration
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 3; # Keep only 3 most recent generations
        consoleMode = "auto";
        editor = false; # Security: disable boot entry editing
      };
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Combined kernel parameters for performance and Intel graphics
    kernelParams = config.mySystem.perfKernelParams ++ config.mySystem.intelFlags;
    
    # Optimized initrd
    initrd = {
      compressor = "zstd";
      compressorArgs = [ "-19" "-T0" ];
      systemd.enable = true;
    };
    
    # Smooth boot experience
    plymouth = {
      enable = true;
      theme = "breeze";
    };

    # Hardware virtualization and video routing
    kernelModules = [ "kvm-intel" "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
    
    # System performance tuning
    kernel.sysctl = {
      # Memory management
      "vm.swappiness" = config.mySystem.performance.swapiness;
      "vm.vfs_cache_pressure" = config.mySystem.performance.cachePressure;
      "vm.dirty_ratio" = config.mySystem.performance.dirtyRatio;
      "vm.dirty_background_ratio" = config.mySystem.performance.dirtyBackgroundRatio;
      
      # Advanced memory management
      "vm.max_map_count" = config.mySystem.performance.maxMapCount;
      "vm.mmap_min_addr" = config.mySystem.performance.mmapMinAddr;
      "vm.overcommit_memory" = config.mySystem.performance.overcommitMemory;
      "vm.overcommit_ratio" = config.mySystem.performance.overcommitRatio;
    };
  };
}