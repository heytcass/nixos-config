# Wayland/GNOME compatible keyboard layout management
# Handles QMK keyboards with hardware layouts vs built-in keyboards

{ config, lib, pkgs, ... }:

{
  # Keep console keymap as Colemak for built-in keyboard at GDM
  # Note: ZSA Voyager will have double Colemak remapping at login screen
  # Use built-in keyboard for password entry at GDM
  console = {
    keyMap = "colemak";
    useXkbConfig = false;
  };
  # Install required tools for GNOME keyboard management
  environment.systemPackages = with pkgs; [
    libevdev  # For evtest to identify devices
    evtest    # For testing input devices
    python3   # For custom keyboard detection script
  ];

  # Create keyboard layout management script
  environment.etc."gnome-keyboard-manager.py" = {
    text = ''
      #!/usr/bin/env python3
      """
      GNOME Keyboard Layout Manager for mixed QMK/built-in keyboards
      
      This script detects ZSA Voyager keyboards and manages GNOME input sources
      to avoid double Colemak remapping.
      """
      
      import subprocess
      import time
      import json
      import os
      import sys
      from pathlib import Path
      
      def get_input_devices():
          """Get list of input devices from /proc/bus/input/devices"""
          devices = []
          try:
              with open("/proc/bus/input/devices", "r") as f:
                  content = f.read()
              
              device_blocks = content.strip().split("\n\n")
              for block in device_blocks:
                  if "Handlers=" in block and "event" in block:
                      device = {}
                      for line in block.split("\n"):
                          if line.startswith("N: Name="):
                              device["name"] = line.split("Name=")[1].strip(" \"")
                          elif line.startswith("I: Bus="):
                              # Extract vendor and product IDs
                              parts = line.split()
                              for part in parts:
                                  if part.startswith("Vendor="):
                                      device["vendor"] = part.split("=")[1]
                                  elif part.startswith("Product="):
                                      device["product"] = part.split("=")[1]
                          elif line.startswith("H: Handlers="):
                              handlers = line.split("Handlers=")[1].strip()
                              if "kbd" in handlers:
                                  device["is_keyboard"] = True
                      
                      if device.get("is_keyboard") and device.get("name"):
                          devices.append(device)
                          
          except Exception as e:
              print(f"Error reading input devices: {e}")
          
          return devices
      
      def has_zsa_voyager():
          """Check if ZSA Voyager is connected"""
          devices = get_input_devices()
          for device in devices:
              # ZSA Voyager vendor ID is 3297 (0x0ce1)
              if device.get("vendor") == "3297" or ("voyager" in device.get("name", "").lower()):
                  print(f"Found ZSA device: {device}")
                  return True
          return False
      
      def get_current_input_sources():
          """Get current GNOME input sources"""
          try:
              result = subprocess.run(["gsettings", "get", "org.gnome.desktop.input-sources", "sources"], 
                                    capture_output=True, text=True)
              return result.stdout.strip()
          except Exception as e:
              print(f"Error getting input sources: {e}")
              return None
      
      def set_input_sources(sources_str):
          """Set GNOME input sources"""
          try:
              subprocess.run(["gsettings", "set", "org.gnome.desktop.input-sources", "sources", sources_str])
              print(f"Set input sources to: {sources_str}")
              return True
          except Exception as e:
              print(f"Error setting input sources: {e}")
              return False
      
      def main():
          """Main keyboard layout management logic"""
          print("GNOME Keyboard Layout Manager starting...")
          
          # Check if ZSA Voyager is present
          has_voyager = has_zsa_voyager()
          current_sources = get_current_input_sources()
          
          print(f"ZSA Voyager detected: {has_voyager}")
          print(f"Current input sources: {current_sources}")
          
          if has_voyager:
              # ZSA Voyager present - use US layout (no remapping)
              # The hardware already provides Colemak layout
              target_sources = "[('xkb', 'us')]"
              print("ZSA Voyager detected - switching to US layout (hardware Colemak)")
          else:
              # No ZSA Voyager - use Colemak for built-in keyboard
              target_sources = "[('xkb', 'us+colemak')]"
              print("No ZSA Voyager - using Colemak layout for built-in keyboard")
          
          # Only change if different from current
          if current_sources != target_sources:
              if set_input_sources(target_sources):
                  print(f"Successfully changed layout from {current_sources} to {target_sources}")
              else:
                  print(f"Failed to change layout")
          else:
              print("Layout already correct - no change needed")
      
      if __name__ == "__main__":
          main()
    '';
    mode = "0755";
  };

  # Systemd service to manage keyboard layouts
  systemd.user.services.gnome-keyboard-manager = {
    description = "GNOME Keyboard Layout Manager for QMK keyboards";
    wantedBy = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    script = ''
      # Wait for GNOME to be fully loaded
      sleep 10
      
      # Run the keyboard manager with full environment
      ${pkgs.python3}/bin/python3 /etc/gnome-keyboard-manager.py
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = false;
      Restart = "no";
    };
    environment = {
      PATH = lib.mkForce "${pkgs.glib}/bin:/run/current-system/sw/bin";
    };
  };

  # Udev rule to trigger keyboard layout check when USB devices change
  services.udev.extraRules = ''
    # Trigger keyboard layout check when ZSA devices are connected/disconnected
    ACTION=="add|remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="3297", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="gnome-keyboard-manager.service"
    
    # Also trigger on any keyboard device changes
    ACTION=="add|remove", SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="*keyboard*", TAG+="systemd", ENV{SYSTEMD_USER_WANTS}+="gnome-keyboard-manager.service"
  '';
}