# Per-device keyboard layout configuration
# Handles mixed keyboard scenarios where external QMK keyboards have
# hardware-level layouts and built-in keyboards need OS-level remapping

{ config, lib, pkgs, ... }:

{
  # Install xinput for per-device configuration
  environment.systemPackages = with pkgs; [
    xorg.xinput
    xorg.setxkbmap
  ];

  # Create script for per-device keyboard layout setup
  environment.etc."xkb-device-setup.sh" = {
    text = ''
      #!/bin/sh
      # Set ZSA Voyager to US QWERTY (no remapping since it has hardware Colemak)
      # The device name might vary, check with: xinput list
      
      # Wait for X server to be ready
      sleep 2
      
      # Find ZSA Voyager keyboard and set it to US layout
      VOYAGER_ID=$(xinput list | grep -i "voyager\|zsa" | grep -o 'id=[0-9]*' | cut -d= -f2 | head -1)
      if [ -n "$VOYAGER_ID" ]; then
          echo "Setting ZSA Voyager (ID: $VOYAGER_ID) to US layout"
          setxkbmap -device "$VOYAGER_ID" us
      fi
      
      # Find built-in keyboard and ensure it uses Colemak
      BUILTIN_ID=$(xinput list | grep -i "at translated set\|internal\|integrated" | grep -o 'id=[0-9]*' | cut -d= -f2 | head -1)
      if [ -n "$BUILTIN_ID" ]; then
          echo "Setting built-in keyboard (ID: $BUILTIN_ID) to Colemak layout"  
          setxkbmap -device "$BUILTIN_ID" us colemak
      fi
    '';
    mode = "0755";
  };

  # Simple udev rule to trigger keyboard setup script
  services.udev.extraRules = ''
    # ZSA Voyager - trigger keyboard setup when connected
    ACTION=="add", SUBSYSTEM=="input", ATTRS{idVendor}=="3297", ATTRS{idProduct}=="0791", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="keyboard-layout-setup.service"
  '';

  # GNOME session startup script to configure keyboards
  systemd.user.services.keyboard-layout-setup = {
    description = "Configure per-device keyboard layouts";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    script = ''
      # Wait for desktop to be ready and X server available
      sleep 5
      
      # Check if DISPLAY is set, if not try to find it
      if [ -z "$DISPLAY" ]; then
        export DISPLAY=:0
      fi
      
      # Run the keyboard setup script
      /etc/xkb-device-setup.sh
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;  # Allow it to be triggered multiple times
      Environment = "PATH=${pkgs.xorg.xinput}/bin:${pkgs.xorg.setxkbmap}/bin:/run/current-system/sw/bin";
    };
  };
}