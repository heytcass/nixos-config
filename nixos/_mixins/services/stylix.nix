# Stylix unified theming configuration
{
  pkgs,
  ...
}:

{
  stylix = {
    # Enable Stylix
    enable = true;

    # Base16 color scheme - Claude-inspired theme
    base16Scheme = {
      base00 = "1a1915"; # Background
      base01 = "1f1e1d"; # Lighter background
      base02 = "3a3529"; # Selection background
      base03 = "6b6454"; # Comments
      base04 = "9b967f"; # Foreground (darker)
      base05 = "faf9f5"; # Foreground (light)
      base06 = "fefef9"; # Foreground (lighter)
      base07 = "ffffff"; # Foreground (lightest)
      base08 = "ab2b3f"; # Red (error)
      base09 = "d77757"; # Orange (Claude brand)
      base0A = "966c1e"; # Yellow (warning)
      base0B = "2c7a39"; # Green (success)
      base0C = "7fc8ff"; # Cyan (info)
      base0D = "5a9fd4"; # Blue (info secondary)
      base0E = "c96442"; # Magenta (Claude secondary)
      base0F = "8b4513"; # Brown (Claude tertiary)
    };

    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.inter;
        name = "Inter Nerd Font";
      };

      serif = {
        package = pkgs.source-serif;
        name = "Source Serif 4";
      };
    };

    # Cursor theme
    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # Disable auto-enable to avoid conflicts with existing theming
    autoEnable = false;

    targets = {
      # Enable system-level theming
      console.enable = true;
      plymouth.enable = true; # Override base.nix theme
      gtk.enable = true; # Override existing GTK theme
      gnome.enable = true; # Theme GNOME components

      # Browser theming not available at NixOS level
      # chromium.enable = true; # Not available as NixOS target
      # firefox.enable = true; # Not available as NixOS target

      # Keep Qt disabled to avoid conflicts
      qt.enable = false;
    };

    # Opacity settings
    opacity = {
      applications = 1.0;
      terminal = 0.95;
      desktop = 1.0;
      popups = 0.95;
    };

    # Polarity (dark/light)
    polarity = "dark";

    # Image settings (wallpaper) - using Claude brand colors
    image = pkgs.runCommand "claude-wallpaper" { } ''
      ${pkgs.imagemagick}/bin/convert -size 1920x1080 gradient:"#1a1915"-"#3a3529" $out
    '';
  };
}
