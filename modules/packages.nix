{ config, pkgs, ... }:

{
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # CLI tools
    wget
    kitty
    git

    # GUI applications
    google-chrome
    bitwarden-desktop
    todoist-electron
    slack
    teams-for-linux
  ];

  # Wayland support for Electron apps
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
