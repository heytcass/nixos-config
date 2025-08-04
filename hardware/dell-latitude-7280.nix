# Dell Latitude 7280 Hardware Profile
# Hardware-specific configuration for Latitude 7280 (test/development system)

{ config, pkgs, lib, ... }:

{
  # Hardware-specific settings for Dell Latitude 7280
  mySystem.hardware = {
    hostname = "transporter";
    timezone = "America/Detroit";
    locale = "en_US.UTF-8";
    keyboardLayout = "us";
    keyboardVariant = "colemak";
  };

  # Performance settings optimized for Latitude 7280
  mySystem.performance = {
    # Skylake architecture (6th/7th gen Intel Core i7-7600U)
    cpuArchitecture = "skylake";
    cpuTune = "skylake";
    
    # Memory management for typical 8GB system
    swapiness = 10;
    cachePressure = 50;
    dirtyRatio = 15;
    dirtyBackgroundRatio = 5;
    
    # ZRAM configuration - slightly higher for lower RAM system
    zramPercent = 60;
    zramAlgorithm = "zstd";
    
    # Memory mapping
    maxMapCount = 262144;
    mmapMinAddr = 65536;
    overcommitMemory = 1;
    overcommitRatio = 50;
  };

  # Intel graphics optimizations for Latitude 7280
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