# Niri desktop environment mixin
# Provides modern scrollable-tiling Wayland compositor with optimizations

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./wayland-common.nix
  ];
  # Environment configuration
  environment = {
    # Niri-specific packages (common Wayland tools provided by wayland-common.nix)
    systemPackages = with pkgs; [
      # Niri compositor from flake
      inputs.niri.packages.${pkgs.system}.niri
      
      # Sway-specific tools for Niri
      swaylock-effects # Screen locker with effects
      swayidle # Idle management daemon
      swaybg # Wallpaper daemon
      wlsunset # Manual blue light filter control
    ];

    # Niri configuration
    etc."niri/config.kdl".text = ''
      // Niri configuration in KDL format

      // Input configuration - maintain Colemak layout
      input {
          keyboard {
              xkb {
                  layout "us"
                  variant "colemak"
              }
              repeat-delay 600
              repeat-rate 25
          }

          touchpad {
              natural-scroll true
              tap true
              dwt true
              tap-button-map "lrm"
          }

          mouse {
              natural-scroll false
              accel-speed 0.0
          }

          trackpoint {
              natural-scroll false
              accel-speed 0.0
          }
      }

      // Output configuration
      output "eDP-1" {
          mode "1920x1080@60.000"
          scale 1.0
          position x=0 y=0
      }

      // Layout configuration
      layout {
          gaps 16
          center-focused-column "never"
          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }
          default-column-width { proportion 0.5; }
          focus-ring {
              width 4
              active-color "#7fc8ff"
              inactive-color "#505050"
          }
          border {
              width 2
              active-color "#7fc8ff"
              inactive-color "#505050"
          }
      }

      // Window rules
      window-rule {
          match app-id="org.gnome.Calculator"
          default-column-width { fixed 300; }
      }

      window-rule {
          match app-id="org.pulseaudio.pavucontrol"
          default-column-width { fixed 400; }
      }

      // Animations
      animations {
          slowdown 1.0
          horizontal-view-movement {
              spring damping-ratio=1.0 stiffness=800 epsilon=0.0001
          }
          window-open {
              duration-ms 150
              curve "ease-out-expo"
          }
          window-close {
              duration-ms 150
              curve "ease-out-expo"
          }
          workspace-switch {
              spring damping-ratio=1.0 stiffness=1000 epsilon=0.0001
          }
      }

      // Screenshot configuration
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      // Keybindings
      binds {
          // Basic window management
          Mod+Return { spawn "ghostty"; }
          Mod+D { spawn "wofi" "--show" "drun"; }
          Mod+Alt+L { spawn "swaylock-effects"; }

          // Window operations
          Mod+Q { close-window; }
          Mod+H { focus-column-left; }
          Mod+L { focus-column-right; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }

          // Move windows
          Mod+Shift+H { move-column-left; }
          Mod+Shift+L { move-column-right; }
          Mod+Shift+J { move-window-down; }
          Mod+Shift+K { move-window-up; }

          // Workspaces
          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }
          Mod+0 { focus-workspace 10; }

          // Move to workspace
          Mod+Shift+1 { move-window-to-workspace 1; }
          Mod+Shift+2 { move-window-to-workspace 2; }
          Mod+Shift+3 { move-window-to-workspace 3; }
          Mod+Shift+4 { move-window-to-workspace 4; }
          Mod+Shift+5 { move-window-to-workspace 5; }
          Mod+Shift+6 { move-window-to-workspace 6; }
          Mod+Shift+7 { move-window-to-workspace 7; }
          Mod+Shift+8 { move-window-to-workspace 8; }
          Mod+Shift+9 { move-window-to-workspace 9; }
          Mod+Shift+0 { move-window-to-workspace 10; }

          // Column manipulation
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }
          Mod+Shift+Minus { set-window-height "-10%"; }
          Mod+Shift+Equal { set-window-height "+10%"; }

          // Screenshots
          Print { screenshot; }
          Mod+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          // Media keys
          XF86AudioRaiseVolume { spawn "pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%"; }
          XF86AudioLowerVolume { spawn "pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%"; }
          XF86AudioMute { spawn "pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle"; }
          XF86MonBrightnessUp { spawn "brightnessctl" "set" "5%+"; }
          XF86MonBrightnessDown { spawn "brightnessctl" "set" "5%-"; }
          XF86AudioPlay { spawn "playerctl" "play-pause"; }
          XF86AudioNext { spawn "playerctl" "next"; }
          XF86AudioPrev { spawn "playerctl" "previous"; }

          // Exit
          Mod+Shift+E { quit; }
      }

      // Spawn at startup
      spawn-at-startup "waybar"
      spawn-at-startup "swaync"
      spawn-at-startup "swayidle" "-w" "timeout" "300" "swaylock-effects" "timeout" "600" "niri" "msg" "action" "power-off-monitors" "resume" "niri" "msg" "action" "power-on-monitors" "before-sleep" "swaylock-effects"
      spawn-at-startup "swaybg" "-i" "~/.config/wallpaper.jpg" "-m" "fill"
    '';

    # Environment variables for Wayland
    sessionVariables = {
      # Existing Wayland variables are already set in base.nix
      # Just add Niri-specific ones
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  # Services configuration
  services = {
    # X11 server for XWayland compatibility
    xserver = {
      enable = true;
      excludePackages = [ pkgs.xterm ];
      xkb = {
        layout = "us";
        variant = "colemak";
      };
    };

    # Display manager - GDM works well with Wayland compositors
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Printing disabled by default (same as other desktop mixins)
    printing.enable = false;
  };

  # Security and authentication
  security = {
    polkit.enable = true;
    pam.services.swaylock = { };
  };

  # XDG Portal for proper Wayland app integration
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config.common.default = "*";
  };

  # Hardware acceleration is handled in base.nix
}
