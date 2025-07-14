# Matugen Material You color generation configuration
{
  inputs,
  pkgs,
  ...
}:

{
  # Import the matugen module
  imports = [
    inputs.matugen.nixosModules.default
  ];

  # Add matugen package to system packages
  environment.systemPackages = [
    inputs.matugen.packages.${pkgs.system}.default
  ];

  # Configure matugen
  programs.matugen = {
    enable = true;
    
    # Use Claude brand color as base
    source_color = "#d77757"; # Claude orange from Stylix config
    
    # Color scheme variant
    variant = "dark";
    
    # Contrast adjustment
    contrast = 0.0;
    
    # JSON output format
    jsonFormat = "hex";
    
    # Palette generation type
    type = "scheme-tonal-spot";
    
    # Custom colors from existing Stylix theme
    custom_colors = {
      claude_orange = "#d77757";
      claude_secondary = "#c96442";
      claude_tertiary = "#8b4513";
      claude_background = "#1a1915";
      claude_surface = "#1f1e1d";
    };
    
    # Template configurations for various applications
    templates = {
      # Generate colors for potential Hyprland integration
      hyprland = {
        input_path = "/home/tom/.nixos/nixos/_mixins/services/matugen-templates/hyprland.conf";
        output_path = "~/.config/hypr/colors.conf";
      };
      
      # Generate colors for shell/terminal applications
      shell = {
        input_path = "/home/tom/.nixos/nixos/_mixins/services/matugen-templates/shell-colors.sh";
        output_path = "~/.config/shell/colors.sh";
      };
    };
  };
}