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
              clickfinger_behavior = true
          }
          sensitivity = 0
      }

      # General settings with Claude theme
      general {
          # Claude's signature terracotta for borders and accents
          col.active_border = rgb(d97757) rgb(c96442) 45deg
          col.inactive_border = rgb(30302e)

          # Dark theme with Claude's refined spacing
          border_size = 2
          gaps_in = 8
          gaps_out = 16
          layout = dwindle
          allow_tearing = false

          # Use Claude's warm terracotta for resize borders
          resize_on_border = true
      }

      # Decoration with Claude aesthetics
      decoration {
          # Subtle rounding matching Claude's modern design
          rounding = 8

          # Claude's shadow system
          drop_shadow = true
          shadow_range = 12
          shadow_render_power = 3
          col.shadow = rgba(1f1e1d99)  # Claude's dark background with opacity

          # Blur settings with Claude's refined aesthetic
          blur {
              enabled = true
              size = 6
              passes = 2
              new_optimizations = true
              xray = false
              ignore_opacity = false
          }
      }

      # Animations with Claude's polished UX
      animations {
          enabled = true

          # Smooth animations reflecting Claude's polished UX
          bezier = claudeEase, 0.25, 0.1, 0.25, 1.0

          animation = windows, 1, 6, claudeEase
          animation = windowsOut, 1, 6, claudeEase, popin 80%
          animation = border, 1, 8, claudeEase
          animation = borderangle, 1, 8, claudeEase
          animation = fade, 1, 6, claudeEase
          animation = workspaces, 1, 6, claudeEase
      }

      # Layout
      dwindle {
          pseudotile = true
          preserve_split = true
      }

      # Workspace rules with Claude's semantic color system
      workspace = 1, border_color = rgb(2c7a39)    # Success workspace (development/terminal)
      workspace = 2, border_color = rgb(d97757)    # Claude brand workspace (main work)
      workspace = 3, border_color = rgb(966c1e)    # Warning workspace (monitoring/logs)
      workspace = 4, border_color = rgb(ab2b3f)    # Error workspace (debugging)
      workspace = 5, border_color = rgb(5769f7)    # Permission workspace (admin tasks)
      workspace = 6, border_color = rgb(006666)    # Plan mode workspace (planning/design)

      # Window rules with Claude theme colors for installed packages
      windowrule = float, ^(pavucontrol)$
      windowrule = float, ^(thunar)$
      windowrule = size 800 600, ^(thunar)$

      # Terminal applications use Claude CLI's color scheme
      windowrule = bordercolor rgb(215 119 87), ^(ghostty)$

      # System applications use Claude's secondary colors
      windowrule = bordercolor rgb(194 192 182), ^(thunar)$

      # Media applications
      windowrule = bordercolor rgb(201 100 66), ^(mpv)$
      windowrule = bordercolor rgb(201 100 66), ^(imv)$

      # Keybindings - using Super (Windows/Cmd) key
      $mod = SUPER

      # Application launchers with Claude theme awareness
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

      # Workspaces with Claude's semantic meaning
      bind = $mod, 1, workspace, 1  # Development/Terminal (Success Green)
      bind = $mod, 2, workspace, 2  # Main Work (Claude Brand)
      bind = $mod, 3, workspace, 3  # Monitoring (Warning Amber)
      bind = $mod, 4, workspace, 4  # Debugging (Error Red)
      bind = $mod, 5, workspace, 5  # Admin (Permission Blue)
      bind = $mod, 6, workspace, 6  # Planning (Plan Mode Teal)
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

      # Startup applications with Claude theme integration
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

  # Hardware acceleration is handled in base.nix
}
