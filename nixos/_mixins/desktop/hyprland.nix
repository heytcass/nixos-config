# Hyprland desktop environment mixin
# Provides modern Wayland compositor with optimizations and essential tools

{
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./common.nix
    ./wayland-common.nix
  ];
  # Hyprland window manager
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  # Environment configuration consolidated
  environment = {
    # Hyprland-specific packages (common Wayland tools provided by wayland-common.nix)
    systemPackages = with pkgs; [
      # Official Hyprland ecosystem tools (from nixpkgs)
      hyprpaper # Official wallpaper utility
      hyprpicker # Official color picker
      hyprlock # GPU-accelerated screen locker
      hypridle # Official idle management
      hyprsunset # Blue light filter
    ];

  };

  # Hyprland-specific session variables
  environment.sessionVariables = {
    # Existing Wayland variables are already set in base.nix and common.nix
    # Just add Hyprland-specific ones
    WLR_NO_HARDWARE_CURSORS = "1"; # Fix cursor issues on some hardware
    XDG_CURRENT_DESKTOP = "Hyprland";
    XDG_SESSION_DESKTOP = "Hyprland";
  };

  # Hardware acceleration is handled in base.nix
}
