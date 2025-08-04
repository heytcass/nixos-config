# Intel laptop base configuration
# Common settings for all Intel-based laptop systems

{ config, pkgs, lib, ... }:

{
  # Common hardware and locale settings
  mySystem.hardware = {
    timezone = "America/Detroit";
    locale = "en_US.UTF-8";
    keyboardLayout = "us";
    keyboardVariant = "colemak";
  };

  # Base performance settings for Intel systems
  mySystem.performance = {
    # Memory management
    swapiness = 10;
    cachePressure = 50;
    dirtyRatio = 15;
    dirtyBackgroundRatio = 5;
    
    # ZRAM configuration
    zramAlgorithm = "zstd";
    
    # Memory mapping
    maxMapCount = 262144;
    mmapMinAddr = 65536;
    overcommitMemory = 1;
    overcommitRatio = 50;
  };

  # Common Intel graphics optimizations
  mySystem.intelFlags = [
    "i915.fastboot=1"
    "i915.enable_psr=1"
    "i915.enable_fbc=1"
    "i915.enable_guc=2"
    "i915.enable_dc=2"
  ];

  # Common performance kernel parameters
  mySystem.perfKernelParams = [
    "mitigations=auto"
    "nowatchdog"
    "intel_iommu=on"
    "iommu=pt"
    "quiet"
    "splash"
  ];
}