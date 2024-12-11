{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.packages = {
    enable = mkEnableOption "custom package selection";
    
    # Add options for different package groups
    gui.enable = mkEnableOption "GUI applications";
    development.enable = mkEnableOption "development tools";
    
    # Option for Wayland support
    wayland.enable = mkEnableOption "Wayland support for applications";
  };

  config = mkIf config.modules.packages.enable (mkMerge [
    {
      # Allow unfree packages
      nixpkgs.config.allowUnfree = true;

      # Base packages that are always installed
      environment.systemPackages = with pkgs; [
        wget
        gh
        git
      ];
    }

    (mkIf config.modules.packages.gui.enable {
      environment.systemPackages = with pkgs; [
        bitwarden-desktop
        google-chrome
        marp-cli
        obsidian
        slack
        teams-for-linux
        todoist-electron
        zoom-us
      ];
    })

    (mkIf config.modules.packages.wayland.enable {
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    })
  ]);
}