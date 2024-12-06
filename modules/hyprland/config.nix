{ config, lib, ... }:

with lib;
let
  cfg = config.modules.hyprland;
  
  # Helper function to generate monitor config strings
  monitorConfig = monitor: 
    "monitor=${monitor.name},${monitor.resolution},${monitor.position},${toString monitor.scale}";
  
  # Join list of strings with newlines
  concatStringsNewline = strings: concatStringsSep "\n" strings;
in
{
  config = mkIf cfg.enable {
    programs.hyprland.extraConfig = ''
      # Monitor configuration
      ${concatStringsNewline (map monitorConfig cfg.monitors)}
      
      # Set variables
      $mainMod = SUPER
      
      # Theme colors
      general {
        border_size = 2
        gaps_in = 4
        gaps_out = 8
        col.active_border = ${cfg.theme.colors.accent}
        col.inactive_border = ${cfg.theme.colors.background}
      }
      
      # Some default env vars.
      env = XCURSOR_SIZE,24
      
      # Input configuration
      input {
        kb_layout = ${config.modules.desktop.keyboard.layout}
        kb_variant = ${config.modules.desktop.keyboard.variant}
        follow_mouse = 1
        touchpad {
          natural_scroll = true
          tap-to-click = true
        }
      }
      
      # Basic keybindings
      bind = $mainMod, Return, exec, foot
      bind = $mainMod, Q, killactive,
      bind = $mainMod SHIFT, E, exit,
      bind = $mainMod, E, exec, thunar
      bind = $mainMod, Space, exec, wofi --show drun
      bind = $mainMod SHIFT, Space, exec, wofi --show run
      
      # Window management
      bind = $mainMod, F, fullscreen
      bind = $mainMod, V, togglefloating
      
      # Move focus with mainMod + arrow keys
      bind = $mainMod, left, movefocus, l
      bind = $mainMod, right, movefocus, r
      bind = $mainMod, up, movefocus, u
      bind = $mainMod, down, movefocus, d
      
      # Switch workspaces
      bind = $mainMod, 1, workspace, 1
      bind = $mainMod, 2, workspace, 2
      bind = $mainMod, 3, workspace, 3
      bind = $mainMod, 4, workspace, 4
      bind = $mainMod, 5, workspace, 5
      bind = $mainMod, 6, workspace, 6
      bind = $mainMod, 7, workspace, 7
      bind = $mainMod, 8, workspace, 8
      bind = $mainMod, 9, workspace, 9
      bind = $mainMod, 0, workspace, 10
      
      # Move windows to workspaces
      bind = $mainMod SHIFT, 1, movetoworkspace, 1
      bind = $mainMod SHIFT, 2, movetoworkspace, 2
      bind = $mainMod SHIFT, 3, movetoworkspace, 3
      bind = $mainMod SHIFT, 4, movetoworkspace, 4
      bind = $mainMod SHIFT, 5, movetoworkspace, 5
      bind = $mainMod SHIFT, 6, movetoworkspace, 6
      bind = $mainMod SHIFT, 7, movetoworkspace, 7
      bind = $mainMod SHIFT, 8, movetoworkspace, 8
      bind = $mainMod SHIFT, 9, movetoworkspace, 9
      bind = $mainMod SHIFT, 0, movetoworkspace, 10
      
      ${optionalString cfg.wallpaper.enable ''
        # Set wallpaper
        exec-once = swaybg -i ${cfg.wallpaper.path} --mode fill
      ''}
      
      # Start bar and other services
      exec-once = waybar
      exec-once = dunst
    '';
  };
}