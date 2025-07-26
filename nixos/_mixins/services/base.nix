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
      tmpfsSize = "8G"; # Sufficient for large builds with 16GB RAM
    };

    # Enable kernel modules for hardware monitoring
    kernelModules = [
      "coretemp"
      "nct6775"
    ];
  };

  # Console keyboard configuration - critical for SDDM Colemak support
  console = {
    useXkbConfig = true; # Inherit keyboard layout from services.xserver.xkb
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
        # Official Nix cache (highest priority)
        "https://cache.nixos.org/"
        # Personal cache (second priority for frequent hits)
        "https://tcass-nixos-config.cachix.org"
        # Community caches (third priority)
        "https://nix-community.cachix.org"
        # Specialized desktop environment caches
        "https://hyprland.cachix.org"
        "https://niri.cachix.org"
        "https://nixpkgs-wayland.cachix.org"
        # Development and application-specific caches
        "https://devenv.cachix.org"
        "https://ghostty.cachix.org"
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
      persistent = true; # Run even if system was off during scheduled time
    };

    # Additional source cleanup for large cached sources
    extraOptions = ''
      # More aggressive cleanup for source caches
      min-free = ${toString (1024 * 1024 * 1024)} # 1GB
      max-free = ${toString (5 * 1024 * 1024 * 1024)} # 5GB

      # Keep fewer derivations to reduce source cache buildup
      keep-derivations = false
      keep-outputs = false
    '';
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
    gvfs.enable = true;

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

    # SMART disk monitoring
    smartd = lib.mkIf (!isISO) {
      enable = true;
      autodetect = true;
      notifications = {
        x11.enable = false;
        wall.enable = true;
      };
    };
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

    # USB device notifications and auto-actions
    SUBSYSTEMS=="usb", ACTION=="add", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}="usb-device-added@%k.service"
    SUBSYSTEMS=="usb", ACTION=="remove", ATTRS{idVendor}=="*", ATTRS{idProduct}=="*", \
      TAG+="systemd", ENV{SYSTEMD_WANTS}="usb-device-removed@%k.service"

    # USB storage device auto-mounting with better permissions
    SUBSYSTEMS=="usb", KERNEL=="sd[a-z][0-9]*", ACTION=="add", \
      ATTRS{removable}=="1", TAG+="systemd", ENV{SYSTEMD_WANTS}="usb-storage-mount@%k.service"

    # Logitech Unifying receiver optimization
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="046d", ATTRS{idProduct}=="c52b|c532|c534", \
      MODE="0664", GROUP="input", TAG+="uaccess"

    # Dell dock ethernet interface naming
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0bda", ATTRS{idProduct}=="8153", \
      NAME="dock-eth", TAG+="systemd"
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

  # USB device management services
  systemd.user.services = lib.mkIf (!isISO) {
    "usb-device-added@" = {
      description = "Handle USB device insertion";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "usb-device-added" ''
          set -e
          DEVICE_PATH="/sys%i"
          if [ -e "$DEVICE_PATH/idVendor" ] && [ -e "$DEVICE_PATH/idProduct" ]; then
            VENDOR=$(cat "$DEVICE_PATH/idVendor")
            PRODUCT=$(cat "$DEVICE_PATH/idProduct")
            MANUFACTURER=$(cat "$DEVICE_PATH/manufacturer" 2>/dev/null || echo "Unknown")
            PRODUCT_NAME=$(cat "$DEVICE_PATH/product" 2>/dev/null || echo "USB Device")

            # Send desktop notification
            ${pkgs.libnotify}/bin/notify-send \
              "USB Device Connected" \
              "$MANUFACTURER $PRODUCT_NAME ($VENDOR:$PRODUCT)" \
              --icon=usb-creator \
              --category=device
          fi
        '';
      };
    };

    "usb-device-removed@" = {
      description = "Handle USB device removal";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "usb-device-removed" ''
          ${pkgs.libnotify}/bin/notify-send \
            "USB Device Disconnected" \
            "USB device removed" \
            --icon=usb-creator \
            --category=device
        '';
      };
    };

    "usb-storage-mount@" = {
      description = "Auto-mount USB storage device";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "usb-storage-mount" ''
          set -e
          DEVICE="/dev/%i"
          # Let udisks2 handle mounting, just send notification
          sleep 2  # Wait for udisks2 to mount
          MOUNT_POINT=$(${pkgs.util-linux}/bin/findmnt -n -o TARGET "$DEVICE" 2>/dev/null || echo "")
          if [ -n "$MOUNT_POINT" ]; then
            LABEL=$(${pkgs.util-linux}/bin/lsblk -n -o LABEL "$DEVICE" 2>/dev/null || echo "USB Drive")
            ${pkgs.libnotify}/bin/notify-send \
              "USB Storage Mounted" \
              "$LABEL mounted at $MOUNT_POINT" \
              --icon=drive-removable-media \
              --category=device.added
          fi
        '';
      };
    };
  };

  # Real-time kit for audio
  security.rtkit.enable = true;

  # Input method support for international typing
  i18n.inputMethod = lib.mkIf (!isISO) {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      uniemoji # Emoji input
    ];
  };

  # GNOME keyring for secure credential storage
  services.gnome.gnome-keyring.enable = lib.mkIf (!isISO) true;

  # PAM integration for automatic keyring unlock
  security.pam.services.login.enableGnomeKeyring = lib.mkIf (!isISO) true;

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

    # Input method variables
    GTK_IM_MODULE = "ibus";
    QT_IM_MODULE = "ibus";
    XMODIFIERS = "@im=ibus";
    INPUT_METHOD = "ibus";
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

      # Desktop applications
      obsidian
      gnome-calculator # Simple calculator app
      gedit # GNOME text editor


      # Hardware monitoring and control
      lm_sensors # Hardware monitoring
      mission-center # Modern hardware monitor (replaces psensor)
      smartmontools # SMART disk monitoring
      nvme-cli # NVMe management tools
      hdparm # Disk parameter management
      usbutils # lsusb and USB debugging
      pciutils # lspci and PCI debugging

      # System information
      inxi # System information tool
      hwinfo # Comprehensive hardware info
      lshw # Hardware listing
      dmidecode # DMI/SMBIOS information

      # Power management tools
      acpi # ACPI information
      linuxPackages.cpupower # CPU frequency management

      # Archive tools
      ouch # Modern Rust-based archive tool (zip, tar, gzip, etc.) - replaces file-roller

      # Keyring management (GNOME keyring is enabled as service)
      seahorse # GUI keyring manager
    ];
}
