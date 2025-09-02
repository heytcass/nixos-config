# Dell Latitude 7280 Hardware Profile
# Hardware-specific configuration for Latitude 7280 (test/development system)

{ config, pkgs, lib, ... }:

{
  imports = [
    ../modules/intel-laptop-base.nix
  ];

  # Hardware-specific settings for Dell Latitude 7280
  mySystem.hardware.hostname = "transporter";

  # Performance settings optimized for Latitude 7280
  mySystem.performance = {
    # 7th Gen Intel Kaby Lake (dual-core with hyperthreading)
    cpuArchitecture = "skylake";
    cpuTune = "skylake";

    # ZRAM configuration - higher for 8GB system vs 16GB
    zramPercent = 60;
  };
}
