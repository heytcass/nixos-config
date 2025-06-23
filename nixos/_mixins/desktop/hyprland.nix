# Hyprland desktop environment mixin
# Provides modern Wayland compositor with optimizations and essential tools

{
  pkgs,
  inputs,
  ...
}:

{
  # Hyprland window manager
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # Environment configuration consolidated
  environment = {
    # Hyprland configuration
    etc."hypr/hyprland.conf".text = ''
      # Monitor configuration (will auto-detect)
      monitor = ,preferred,auto,1

      # Input configuration - maintain Colemak layout
      input {
          kb_layout = us
          kb_variant = colemak
          follow_mouse = 1
          touchpad {
              natural_scroll = true
              disable_while_typing = true
          }
          sensitivity = 0
      }

      # General settings
      general {
          gaps_in = 5
          gaps_out = 10
          border_size = 2
          col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
          col.inactive_border = rgba(595959aa)
          layout = dwindle
          allow_tearing = false
      }

      # Decoration
      decoration {
          rounding = 8
          blur {
              enabled = true
              size = 3
              passes = 1
          }
          drop_shadow = true
          shadow_range = 4
          shadow_render_power = 3
          col.shadow = rgba(1a1a1aee)
      }

      # Animations
      animations {
          enabled = true
          bezier = myBezier, 0.05, 0.9, 0.1, 1.05
          animation = windows, 1, 7, myBezier
          animation = windowsOut, 1, 7, default, popin 80%
          animation = border, 1, 10, default
          animation = borderangle, 1, 8, default
          animation = fade, 1, 7, default
          animation = workspaces, 1, 6, default
      }

      # Layout
      dwindle {
          pseudotile = true
          preserve_split = true
      }

      # Window rules for common applications
      windowrule = float, ^(pavucontrol)$
      windowrule = float, ^(thunar)$
      windowrule = size 800 600, ^(thunar)$

      # Keybindings - using Super (Windows/Cmd) key
      $mod = SUPER

      # Application launchers
      bind = $mod, Return, exec, ghostty
      bind = $mod, D, exec, wofi --show drun
      bind = $mod, E, exec, thunar

      # Window management
      bind = $mod, Q, killactive
      bind = $mod, M, exit
      bind = $mod, V, togglefloating
      bind = $mod, P, pseudo
      bind = $mod, J, togglesplit
      bind = $mod, F, fullscreen, 0

      # Move focus
      bind = $mod, left, movefocus, l
      bind = $mod, right, movefocus, r
      bind = $mod, up, movefocus, u
      bind = $mod, down, movefocus, d

      # Move windows
      bind = $mod SHIFT, left, movewindow, l
      bind = $mod SHIFT, right, movewindow, r
      bind = $mod SHIFT, up, movewindow, u
      bind = $mod SHIFT, down, movewindow, d

      # Workspaces
      bind = $mod, 1, workspace, 1
      bind = $mod, 2, workspace, 2
      bind = $mod, 3, workspace, 3
      bind = $mod, 4, workspace, 4
      bind = $mod, 5, workspace, 5
      bind = $mod, 6, workspace, 6
      bind = $mod, 7, workspace, 7
      bind = $mod, 8, workspace, 8
      bind = $mod, 9, workspace, 9
      bind = $mod, 0, workspace, 10

      # Move to workspace
      bind = $mod SHIFT, 1, movetoworkspace, 1
      bind = $mod SHIFT, 2, movetoworkspace, 2
      bind = $mod SHIFT, 3, movetoworkspace, 3
      bind = $mod SHIFT, 4, movetoworkspace, 4
      bind = $mod SHIFT, 5, movetoworkspace, 5
      bind = $mod SHIFT, 6, movetoworkspace, 6
      bind = $mod SHIFT, 7, movetoworkspace, 7
      bind = $mod SHIFT, 8, movetoworkspace, 8
      bind = $mod SHIFT, 9, movetoworkspace, 9
      bind = $mod SHIFT, 0, movetoworkspace, 10

      # Screenshot
      bind = , Print, exec, grim -g "$(slurp)" - | wl-copy
      bind = $mod, Print, exec, grim - | wl-copy

      # Media keys
      bind = , XF86AudioRaiseVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ +5%
      bind = , XF86AudioLowerVolume, exec, pactl set-sink-volume @DEFAULT_SINK@ -5%
      bind = , XF86AudioMute, exec, pactl set-sink-mute @DEFAULT_SINK@ toggle
      bind = , XF86MonBrightnessUp, exec, brightnessctl set 5%+
      bind = , XF86MonBrightnessDown, exec, brightnessctl set 5%-
      bind = , XF86AudioPlay, exec, playerctl play-pause
      bind = , XF86AudioNext, exec, playerctl next
      bind = , XF86AudioPrev, exec, playerctl previous

      # Mouse bindings
      bindm = $mod, mouse:272, movewindow
      bindm = $mod, mouse:273, resizewindow

      # Startup applications
      exec-once = waybar
      exec-once = swaync
      exec-once = swayidle -w timeout 300 'swaylock-effects' timeout 600 'hyprctl dispatch dpms off' resume 'hyprctl dispatch dpms on' before-sleep 'swaylock-effects'
      exec-once = swaybg -i ~/.config/wallpaper.jpg -m fill
    '';

    # Essential Wayland packages for modern desktop experience
    systemPackages = with pkgs; [
      # Modern Wayland-native tools
      wofi # Rust-based launcher (replaces rofi)
      waybar # Modern status bar
      swaylock-effects # Screen locker with effects
      swaynotificationcenter # Modern notification center
      grim # Screenshot tool
      slurp # Area selection for screenshots
      wl-clipboard # Wayland clipboard utilities
      swayidle # Idle management daemon
      swaybg # Wallpaper daemon
      wlr-randr # Display configuration
      kanshi # Dynamic display configuration

      # File management and media
      xfce.thunar # Lightweight file manager (Hyprland-only)
      xfce.thunar-volman # Volume management for thunar
      xfce.tumbler # Thumbnail support for thunar
      imv # Wayland-native image viewer
      mpv # Video player with Wayland support

      # System utilities
      brightnessctl # Brightness control
      playerctl # Media player control
      pavucontrol # PulseAudio/PipeWire volume control

      # Development and terminal tools
      wev # Wayland event viewer (for debugging)
    ];

    # Environment variables for Wayland
    sessionVariables = {
      # Existing Wayland variables are already set in base.nix
      # Just add Hyprland-specific ones
      WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor issues on some hardware
      XDG_CURRENT_DESKTOP = "Hyprland";
      XDG_SESSION_DESKTOP = "Hyprland";
      XDG_SESSION_TYPE = "wayland";
    };
  };

  # Services configuration consolidated
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

    # Display manager - GDM works well with Hyprland
    displayManager.gdm = {
      enable = true;
      wayland = true;
    };

    # Printing disabled by default (same as GNOME mixin)
    printing.enable = false;
  };

  # Fonts (same as GNOME for consistency)
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
    nerd-fonts.hack
  ];

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
  };

  # Enable hardware acceleration (already handled in base.nix)
  # Ensure proper graphics drivers are loaded
  hardware.graphics.enable = true;
}
