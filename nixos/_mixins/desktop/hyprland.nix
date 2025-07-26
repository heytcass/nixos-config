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

      # Authentication agent for auto-mounting
      polkit_gnome # Polkit authentication agent

      # Screen sharing and portal support
      xdg-desktop-portal-hyprland # Essential for screen sharing in video calls
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

  # Polkit authentication agent service
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
