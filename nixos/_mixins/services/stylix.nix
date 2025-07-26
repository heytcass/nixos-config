# Stylix unified theming configuration
{
  pkgs,
  ...
}:

{
  stylix = {
    # Enable Stylix
    enable = true;

    # Base16 color scheme - Exact Claude colors extracted from website
    base16Scheme = {
      base00 = "262624"; # Main background
      base01 = "1f1e1d"; # Sidebar background
      base02 = "30302e"; # Selection background
      base03 = "4a4a46"; # Comments/disabled
      base04 = "c2c0b6"; # Muted foreground
      base05 = "f8f7f3"; # Primary text
      base06 = "9c9a92"; # Light foreground
      base07 = "faf9f5"; # Brightest text
      base08 = "d63031"; # Red (error states)
      base09 = "c96442"; # Orange (Claude brand - exact)
      base0A = "e17055"; # Yellow/amber (warning)
      base0B = "27ae60"; # Green (success)
      base0C = "74b9ff"; # Cyan (info)
      base0D = "2c82d7"; # Blue (links/actions)
      base0E = "d97757";
      base0F = "7d4a38"; # Brown (secondary accents)
    };

    # Font configuration
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };

      sansSerif = {
        package = pkgs.inter-nerdfont;
        name = "Inter Nerd Font";
      };

      serif = {
        package = pkgs.source-serif;
        name = "Source Serif 4";
      };
    };

    # Cursor theme
    cursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };

    # Enable auto-theming for comprehensive coverage
    autoEnable = true;

    targets = {
      # System-level theming only (application theming moved to Home Manager)
      console.enable = true;
      plymouth.enable = true;
      gtk.enable = true;
      gnome.enable = true;
      qt.enable = true;
      grub.enable = true;
      nixos-icons.enable = true;
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

    # No wallpaper at system level - let home manager handle it
  };
}
