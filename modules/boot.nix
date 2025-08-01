{ config, pkgs, lib, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
in
{
  boot = {
    # Boot loader configuration
    loader = {
      systemd-boot.enable = true;
      timeout = 1;
      efi.canTouchEfiVariables = true;
    };

    # Use latest kernel
    kernelPackages = pkgs.linuxPackages_latest;
    
    # Combined kernel parameters for performance and Intel graphics
    kernelParams = shared.perfKernelParams ++ shared.intelFlags;
    
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
      "vm.swappiness" = shared.performance.swapiness;
      "vm.vfs_cache_pressure" = shared.performance.cachePressure;
      "vm.dirty_ratio" = shared.performance.dirtyRatio;
      "vm.dirty_background_ratio" = shared.performance.dirtyBackgroundRatio;
      
      # Advanced memory management
      "vm.max_map_count" = shared.performance.maxMapCount;
      "vm.mmap_min_addr" = shared.performance.mmapMinAddr;
      "vm.overcommit_memory" = shared.performance.overcommitMemory;
      "vm.overcommit_ratio" = shared.performance.overcommitRatio;
    };
  };
}