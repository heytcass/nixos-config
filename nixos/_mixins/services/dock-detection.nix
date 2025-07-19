# Dock detection and automatic monitor configuration
# Handles Thunderbolt dock connection/disconnection events and triggers appropriate kanshi profiles

{ pkgs, config, ... }:

{
  # Udev rules for dock detection
  services.udev.extraRules = ''
    # Detect dock connection/disconnection via USB device (Foxconn/Hon Hai dock)
    ACTION=="add", SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", ATTRS{idProduct}=="e0a2", TAG+="systemd", ENV{SYSTEMD_WANTS}="dock-connected@%k.service"
    ACTION=="remove", SUBSYSTEM=="usb", ATTRS{idVendor}=="0489", ATTRS{idProduct}=="e0a2", TAG+="systemd", ENV{SYSTEMD_WANTS}="dock-disconnected@%k.service"
    
    # Alternative detection via Thunderbolt bridge
    ACTION=="add", SUBSYSTEM=="pci", ATTRS{vendor}=="0x8086", ATTRS{device}=="0x15d3", TAG+="systemd", ENV{SYSTEMD_WANTS}="thunderbolt-dock-connected.service"
    ACTION=="remove", SUBSYSTEM=="pci", ATTRS{vendor}=="0x8086", ATTRS{device}=="0x15d3", TAG+="systemd", ENV{SYSTEMD_WANTS}="thunderbolt-dock-disconnected.service"
  '';

  # Systemd services for dock events
  systemd.user.services = {
    "dock-connected@" = {
      description = "Handle dock connection";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "dock-connected" ''
          set -e
          
          # Wait a moment for all devices to be discovered
          sleep 2
          
          # Log the event
          echo "$(date): Dock connected - triggering monitor configuration" >> /home/tom/.local/share/dock-events.log
          
          # Force kanshi to re-evaluate profiles
          systemctl --user restart kanshi
          
          # Give kanshi time to apply configuration
          sleep 1
          
          # If kanshi doesn't work, fallback to manual hyprctl (temporary)
          # This can be removed once kanshi dock profiles are working
          if ! systemctl --user is-active kanshi >/dev/null 2>&1; then
            echo "$(date): Kanshi not active, applying manual configuration" >> /home/tom/.local/share/dock-events.log
            hyprctl keyword monitor "DP-3,1920x1080@60,0x0,1" || hyprctl keyword monitor "DP-5,1920x1080@60,0x0,1" || true
            hyprctl keyword monitor "eDP-1,1920x1080@60,1920x0,1" || true
            hyprctl keyword monitor "DP-4,1920x1080@60,3840x0,1,transform,3" || hyprctl keyword monitor "DP-6,1920x1080@60,3840x0,1,transform,3" || true
          fi
        ''}";
        Environment = [
          "PATH=${pkgs.systemd}/bin:${pkgs.hyprland}/bin:/run/current-system/sw/bin"
        ];
      };
    };

    "dock-disconnected@" = {
      description = "Handle dock disconnection";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "dock-disconnected" ''
          set -e
          
          # Log the event
          echo "$(date): Dock disconnected - switching to laptop-only mode" >> /home/tom/.local/share/dock-events.log
          
          # Force kanshi to re-evaluate profiles
          systemctl --user restart kanshi
          
          # Give kanshi time to apply configuration
          sleep 1
          
          # If kanshi doesn't work, fallback to manual hyprctl (temporary)
          if ! systemctl --user is-active kanshi >/dev/null 2>&1; then
            echo "$(date): Kanshi not active, applying laptop-only configuration" >> /home/tom/.local/share/dock-events.log
            hyprctl keyword monitor "eDP-1,1920x1080@60,0x0,1" || true
          fi
        ''}";
        Environment = [
          "PATH=${pkgs.systemd}/bin:${pkgs.hyprland}/bin:/run/current-system/sw/bin"
        ];
      };
    };

    # Alternative Thunderbolt-based detection
    "thunderbolt-dock-connected" = {
      description = "Handle Thunderbolt dock connection";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "thunderbolt-dock-connected" ''
          sleep 3  # Wait longer for Thunderbolt enumeration
          echo "$(date): Thunderbolt dock connected" >> /home/tom/.local/share/dock-events.log
          systemctl --user restart kanshi
        ''}";
      };
    };

    "thunderbolt-dock-disconnected" = {
      description = "Handle Thunderbolt dock disconnection";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.writeShellScript "thunderbolt-dock-disconnected" ''
          echo "$(date): Thunderbolt dock disconnected" >> /home/tom/.local/share/dock-events.log
          systemctl --user restart kanshi
        ''}";
      };
    };
  };

  # Ensure the log directory exists
  system.activationScripts.dock-log-dir = {
    text = ''
      mkdir -p /home/tom/.local/share
      chown tom:users /home/tom/.local/share
    '';
    deps = [];
  };
}