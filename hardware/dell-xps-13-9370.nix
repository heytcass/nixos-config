# Dell XPS 13 9370 Hardware Profile
# Hardware-specific configuration for XPS 13 9370 (production system)

{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/intel-laptop-base.nix
  ];

  # Hardware-specific settings for Dell XPS 13 9370
  mySystem.hardware.hostname = "gti";

  # Performance settings optimized for XPS 13 9370
  mySystem.performance = {
    # 8th Gen Intel Kaby Lake Refresh (quad-core)
    cpuArchitecture = "kabylake";
    cpuTune = "kabylake";

    # ZRAM configuration for 16GB system
    zramPercent = 50;
  };
}
