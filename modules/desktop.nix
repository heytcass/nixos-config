{ config, pkgs, lib, jasper, ... }:

let
  
  # Unwanted GNOME applications
  excludedGnomePackages = with pkgs; [
    epiphany gnome-maps gnome-music gnome-tour gnome-terminal
    simple-scan totem yelp gnome-contacts gnome-calendar gnome-weather
    gnome-software
  ];
  
  # Essential GNOME extensions and utilities
  gnomePackages = with pkgs; [
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.media-controls        # Media control integration
    gnomeExtensions.clipboard-indicator   # Clipboard manager
    # pkgs.jasper-gnome-extension-dev  # Jasper AI development extension (temporarily disabled)
    gnome-tweaks
    playerctl                            # Media player control
    gnome-firmware                       # Firmware update GUI
    sushi                                # GNOME file previewer
  ];
  
  # Professional productivity extensions for copywriting workflow
  productivityPackages = with pkgs; [
    gnomeExtensions.vitals                       # System monitoring
    ddcutil                                      # External monitor control via DDC/CI
    autorandr                                    # Automatic display configuration
  ];
in
{
  services = {
    # X11 and display management
    xserver = {
      enable = true;
      xkb = {
        layout = config.mySystem.hardware.keyboardLayout;
        variant = config.mySystem.hardware.keyboardVariant;
      };
      excludePackages = [ pkgs.xterm ];
    };
    
    # Modern display manager with Wayland
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };
    
    # GNOME desktop environment
    desktopManager.gnome.enable = true;

    # Modern audio stack optimized for professional use
    pulseaudio.enable = false;
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
      
      # Low-latency configuration for professional audio
      extraConfig.pipewire."92-low-latency" = {
        context.properties = {
          default.clock.rate = 48000;
          default.clock.quantum = 32;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 32;
        };
      };
    };
    
    # Additional desktop services
    flatpak.enable = true;      # Sandboxed applications
    geoclue2.enable = true;     # Location services
  };

  # Audio security
  security.rtkit.enable = true;

  # GNOME customization
  environment = {
    gnome.excludePackages = excludedGnomePackages;
    systemPackages = gnomePackages ++ productivityPackages;
  };
}