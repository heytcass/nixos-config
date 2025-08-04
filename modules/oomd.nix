{ config, pkgs, lib, ... }:

{
  # Enhanced systemd-oomd configuration for professional laptop use
  # Provides proactive memory management to prevent system freezes
  
  systemd = {
    # Global oomd configuration 
    oomd = {
      enable = true;
      
      settings = {
        OOM = {
          # Conservative memory pressure duration - act quickly but not too aggressively
          DefaultMemoryPressureDurationSec = config.mySystem.oomd.pressureDurationSec;
          
          # Swap thrashing protection - kill processes causing excessive swap usage
          SwapUsedLimit = config.mySystem.oomd.swapUsedLimit;
        };
      };
    };
    
    # Configure system slice behavior
    slices."system.slice" = {
      sliceConfig = {
        # Protect critical system services from oomd
        ManagedOOMSwap = "kill";
        ManagedOOMMemoryPressure = "kill";
        ManagedOOMMemoryPressureLimit = config.mySystem.oomd.systemMemoryPressureLimit;
        ManagedOOMPreference = "avoid";
      };
    };
    
    # Configure user slice behavior  
    slices."user.slice" = {
      sliceConfig = {
        # User applications are candidates for oomd killing
        ManagedOOMSwap = "kill";
        ManagedOOMMemoryPressure = "kill"; 
        ManagedOOMMemoryPressureLimit = config.mySystem.oomd.userMemoryPressureLimit;
        ManagedOOMPreference = "none";
      };
    };
  };
  
  # Enhanced memory management sysctls to work with oomd
  boot.kernel.sysctl = {
    # Reduce memory pressure detection latency
    "vm.memory_pressure_refresh_ms" = 250;
    
    # Better integration with zram swap
    "vm.watermark_boost_factor" = 15000;
    "vm.watermark_scale_factor" = 125;
  };
}