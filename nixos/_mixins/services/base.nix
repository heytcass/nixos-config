# Base system configuration mixin
# Core system services, boot configuration, and performance optimizations

{
  config,
  pkgs,
  lib,
  isISO,
  ...
}:

{
  # Boot configuration - skip for ISO
  boot = lib.mkIf (!isISO) {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
      timeout = 2; # Faster boot timeout
    };

    # Enhanced Plymouth configuration for cleaner boot
    plymouth = {
      enable = true;
      theme = lib.mkDefault "breeze"; # Clean theme that matches well with GNOME, can be overridden by Stylix
    };

    # Kernel parameters for performance and clean boot
    kernelParams = [
      # Boot experience
      "quiet" # Suppress most kernel messages
      "splash" # Show splash screen
      "vga=current" # Keep current video mode
      "rd.systemd.show_status=false" # Hide systemd status in initrd
      "rd.udev.log_level=3" # Reduce udev log level
      "udev.log_priority=3" # Reduce udev log priority

      # Intel graphics optimization
      "i915.enable_guc=2" # Enable GuC and HuC firmware
      "i915.enable_fbc=1" # Enable framebuffer compression
      "intel_iommu=on" # Enable Intel IOMMU for security/virt

      # Performance optimizations
      "transparent_hugepage=madvise" # Better memory management
      "numa_balancing=enable" # NUMA balancing for multi-core
    ];

    # Further reduce console messages during boot
    consoleLogLevel = 3; # Only show errors and critical messages

    # Kernel sysctl parameters for performance
    kernel.sysctl = {
      # Memory management optimizations
      "vm.swappiness" = 10; # Prefer RAM over swap
      "vm.vfs_cache_pressure" = 50; # Keep filesystem cache longer
      "vm.dirty_ratio" = 15; # Better write performance
      "vm.dirty_background_ratio" = 5; # Background writeback tuning

      # Network performance
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_congestion_control" = "bbr";

      # File system performance
      "fs.file-max" = 2097152;
      "fs.inotify.max_user_watches" = 524288;
    };

    # Move /tmp to tmpfs for better performance (RAM-based)
    tmp = {
      useTmpfs = true;
      tmpfsSize = "2G"; # Adjust based on your needs
    };
  };

  # Internationalization
  i18n = {
    defaultLocale = "en_US.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_US.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "en_US.UTF-8";
      LC_MONETARY = "en_US.UTF-8";
      LC_NAME = "en_US.UTF-8";
      LC_NUMERIC = "en_US.UTF-8";
      LC_PAPER = "en_US.UTF-8";
      LC_TELEPHONE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";
    };
  };

  # Nix configuration
  nix = {
    settings = {
      experimental-features = [
        "flakes"
        "nix-command"
      ];
      substituters = [
        "https://cache.nixos.org/"
        "https://nix-community.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        "https://devenv.cachix.org"
        "https://hyprland.cachix.org"
        "https://niri.cachix.org"
        "https://ghostty.cachix.org"
        "https://tcass-nixos-config.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl5me6XhQeZdPRQQH5No="
        "ghostty.cachix.org-1:QB389yTa6gTyPEY+E/V+W2FaLPmhsNXd63SFxgLiQAE="
        "tcass-nixos-config.cachix.org-1:WveC0/TW42UiS0yLvnYbSw+PKc7FXVP52HeLUwJIseo="
      ];
      auto-optimise-store = true;
      builders-use-substitutes = true;

      # Performance optimizations for faster builds
      max-jobs = "auto";
      cores = 0;
      connect-timeout = 5;
      download-attempts = 3;
      fallback = true;
      keep-going = true;
    };
    optimise.automatic = true;
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  nixpkgs.config.allowUnfree = true;

  # Environment configuration
  environment = {
    # Disable nano system-wide in favor of micro
    defaultPackages =
      with pkgs;
      lib.mkForce [
        # Default packages except nano
        coreutils
        curl
        diffutils
        findutils
        gawk
        gnutar
        gzip
        gnugrep
        gnused
        systemd
        util-linux
        which
        xz
      ];
  };

  # Time zone
  time.timeZone = "America/Detroit";

  # Hardware configuration
  hardware = {
    # Graphics and display
    graphics = {
      enable = true;
      enable32Bit = true;

      # Intel graphics hardware acceleration
      extraPackages = with pkgs; [
        intel-media-driver # VA-API support for Intel graphics
        intel-vaapi-driver # Legacy VA-API support
      ];
    };

    # Bluetooth configuration with modern features
    bluetooth = lib.mkIf (!isISO) {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true; # Enable experimental features like LE Audio
          KernelExperimental = true;
        };
        Policy = {
          AutoEnable = true;
        };
      };
    };

    # Intel microcode updates for security and performance
    cpu.intel.updateMicrocode = lib.mkIf (!isISO) true;
  };

  # Power management for laptops
  powerManagement = lib.mkIf (!isISO) {
    enable = true;
    powertop.enable = true;
    cpuFreqGovernor = lib.mkDefault "powersave"; # Works well with intel_pstate
  };

  services = {
    # Power management - disable power-profiles-daemon when using TLP
    power-profiles-daemon.enable = false;
    tlp = lib.mkIf (!isISO) {
      enable = true;
      settings = {
        # Use Intel P-State driver for better efficiency
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        # Intel P-State specific settings
        CPU_SCALING_DRIVER = "intel_pstate";
        CPU_ENERGY_PERF_POLICY_ON_AC = "balance_performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 50;

        START_CHARGE_THRESH_BAT0 = 40;
        STOP_CHARGE_THRESH_BAT0 = 80;

        WIFI_PWR_ON_AC = "off";
        WIFI_PWR_ON_BAT = "on";
      };
    };

    # Thermal management
    thermald.enable = lib.mkIf (!isISO) true;

    # Firmware updates
    fwupd.enable = lib.mkIf (!isISO) true;

    # Auto-mount USB devices
    udisks2.enable = true;

    # SSD optimization - safe weekly TRIM
    fstrim.enable = lib.mkIf (!isISO) true;

    # IRQ balancing for better multi-core performance
    irqbalance.enable = true;

    # Audio
    pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # Bluetooth audio is automatically enabled with PipeWire
    };
    pulseaudio.enable = false;

    # Optimize systemd-journald
    journald.extraConfig = ''
      SystemMaxUse=100M
      RuntimeMaxUse=50M
      MaxRetentionSec=1week
      ForwardToSyslog=no
    '';
  };

  # Network management (skip for ISO which has its own networking setup)
  networking.networkmanager.enable = lib.mkIf (!isISO) true;

  # I/O scheduler optimization for different storage types
  services.udev.extraRules = lib.mkIf (!isISO) ''
    # Set I/O scheduler for NVMe devices
    ACTION=="add|change", KERNEL=="nvme[0-9]*n[0-9]*", ATTR{queue/scheduler}="none"
    # Set I/O scheduler for SATA SSDs
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
    # Optimize NVMe power management
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{power/control}="auto"
  '';

  # Zram swap for better memory utilization
  zramSwap = lib.mkIf (!isISO) {
    enable = true;
    algorithm = "zstd"; # Better compression ratio than lz4
    memoryPercent = 50; # Use 50% of RAM for compressed swap
    priority = 100; # Higher priority than traditional swap
  };

  # Safe filesystem optimizations
  fileSystems."/".options = lib.mkIf (!isISO) [ "noatime" ];

  # Systemd optimizations for faster boot and better performance
  systemd.extraConfig = lib.mkIf (!isISO) ''
    DefaultTimeoutStartSec=30s
    DefaultTimeoutStopSec=15s
    DefaultDeviceTimeoutSec=15s
  '';

  # Real-time kit for audio
  security.rtkit.enable = true;

  # System fonts (shared across all desktop environments)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
    inter-nerdfont
  ];

  # Fish shell system enablement (required when user shell is fish)
  programs.fish.enable = true;

  # Environment variables for better laptop experience
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "auto";
  };

  # Common system packages
  environment.systemPackages =
    with pkgs;
    lib.optionals (!isISO) [
      fwupd-efi
      firmware-manager # Pop!_OS firmware manager - DE-agnostic fwupd frontend

      # Logitech device support
      logitech-udev-rules
      solaar
    ];
}
