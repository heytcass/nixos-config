# Dell XPS 13 9370 Hardware Profile
# Hardware-specific configuration for XPS 13 9370 (production system)

{ config, pkgs, lib, ... }:

{
  # Hardware-specific settings for Dell XPS 13 9370
  mySystem.hardware = {
    hostname = "gti";
    timezone = "America/Detroit";
    locale = "en_US.UTF-8";
    keyboardLayout = "us";
    keyboardVariant = "colemak";
  };

  # Performance settings optimized for XPS 13 9370
  mySystem.performance = {
    # Skylake architecture (6th/7th gen Intel)
    cpuArchitecture = "skylake";
    cpuTune = "skylake";
    
    # Memory management for 16GB system
    swapiness = 10;
    cachePressure = 50;
    dirtyRatio = 15;
    dirtyBackgroundRatio = 5;
    
    # ZRAM configuration
    zramPercent = 50;
    zramAlgorithm = "zstd";
    
    # Memory mapping
    maxMapCount = 262144;
    mmapMinAddr = 65536;
    overcommitMemory = 1;
    overcommitRatio = 50;
  };

  # Intel graphics optimizations for XPS 13 9370
  mySystem.intelFlags = [
    "i915.fastboot=1"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "i915.enable_guc=2"
    "i915.enable_dc=2"
  ];

  # Performance kernel parameters
  mySystem.perfKernelParams = [
    "mitigations=auto"
    "nowatchdog"
    "intel_iommu=on"
    "iommu=pt"
    "quiet"
    "splash"
  ];
}