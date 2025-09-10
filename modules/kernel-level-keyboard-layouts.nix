# Kernel-level keyboard remapping using keyd
# This bypasses all OS layout remapping and works at GDM/console level

{ config, lib, pkgs, ... }:

{
  # Enable keyd service
  services.keyd = {
    enable = true;
    keyboards = {
      # Built-in laptop keyboard - remap to Colemak at kernel level
      default = {
        ids = [ "*" ];  # Apply to all keyboards by default
        settings = {
          main = {
            # Colemak layout remapping
            # Top row (QWERTY -> Colemak)
            q = "q";
            w = "w"; 
            e = "f";
            r = "p";
            t = "g";
            y = "j";
            u = "l";
            i = "u";
            o = "y";
            p = "semicolon";
            
            # Home row (QWERTY -> Colemak)  
            a = "a";
            s = "r";
            d = "s"; 
            f = "t";
            g = "d";
            h = "h";
            j = "n";
            k = "e";
            l = "i";
            semicolon = "o";
            
            # Bottom row (QWERTY -> Colemak)
            z = "z";
            x = "x";
            c = "c";
            v = "v";
            b = "b";
            n = "k";
            m = "m";
            comma = "comma";
            dot = "dot";
            slash = "slash";
          };
        };
      };
      
      # ZSA Voyager - pass through unchanged (already has hardware Colemak)
      zsa-voyager = {
        ids = [ "3297:1977" ];  # ZSA Voyager vendor:product ID
        settings = {
          main = {
            # Identity mapping - pass all keys through unchanged
            # This effectively disables keyd for the ZSA Voyager
          };
        };
      };
    };
  };

  # Set OS keyboard layout to US (no remapping)
  # Since keyd handles the remapping at kernel level
  console = {
    keyMap = "us";
    useXkbConfig = false;
  };
  
  # Also ensure X11/Wayland uses US layout
  services.xserver.xkb = {
    layout = lib.mkForce "us";
    variant = lib.mkForce "";
  };
  
  # Override the system-wide keyboard setting
  mySystem.hardware = {
    keyboardLayout = lib.mkForce "us";
    keyboardVariant = lib.mkForce "";
  };
}