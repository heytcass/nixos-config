# modules/desktop/default.nix
{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.desktop = {
    enable = mkEnableOption "desktop environment";
    
    keyboard = {
      layout = mkOption {
        type = types.str;
        default = "us";
        description = "Keyboard layout";
      };
      
      variant = mkOption {
        type = types.str;
        default = "colemak";
        description = "Keyboard variant";
      };
    };
  };

  config = mkIf config.modules.desktop.enable {
    # X11 and GNOME settings
    services.xserver = {
      enable = true;
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;
      excludePackages = [ pkgs.xterm ];
      
      # Keyboard settings from module options
      xkb = {
        layout = config.modules.desktop.keyboard.layout;
        variant = config.modules.desktop.keyboard.variant;
      };
    };

    # Disable default GNOME packages
    services.gnome.core-utilities.enable = false;

    # Hardware-related services
    services.fwupd.enable = true;
    services.hardware.bolt.enable = true;

    # Printing (currently disabled)
    services.printing.enable = false;
  };
}