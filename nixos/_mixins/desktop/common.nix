# Common desktop configuration shared across all desktop environments
# Eliminates duplication of X11 server, display manager, keyboard, and security config

{
  pkgs,
  ...
}:

{
  # X11 server configuration (conditional based on needs)
  services.xserver = {
    enable = true; # Needed for XWayland support and GNOME
    excludePackages = [ pkgs.xterm ];
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };

  # Display manager configuration (shared across all desktop environments)
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    settings = {
      # Keyboard layout configuration for SDDM login screen
      X11 = {
        ServerArguments = "-xkblayout us -xkbvariant colemak";
      };
    };
  };

  # Security and authentication (shared across all desktop environments)
  security = {
    polkit.enable = true;
    pam.services.swaylock = { };
  };

  # XDG Portal configuration for Wayland (shared across Wayland compositors)
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-wlr
    ];
    config = {
      common.default = "*";
      hyprland.default = ["hyprland" "gtk"];
    };
  };

  # Printing disabled by default (shared across all desktop environments)
  services.printing.enable = false;

  # Common desktop environment variables
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
  };
}