{ config, pkgs, ... }:

{
  # X11 and GNOME settings
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    excludePackages = [ pkgs.xterm ];
    
    # Keyboard settings
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };

  # Disable default GNOME packages
  services.gnome.core-utilities.enable = false;

  # Hardware-related services
  services.fwupd.enable = true;
  services.hardware.bolt.enable = true;

  # Printing (currently disabled)
  services.printing.enable = false;
}
