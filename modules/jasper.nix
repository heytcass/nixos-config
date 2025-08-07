{ config, pkgs, lib, jasper, ... }:

{
  # Import jasper NixOS module
  imports = [
    jasper.nixosModules.default
  ];

  # Enable jasper companion service
  services.jasperCompanion = {
    enable = true;
    user = "tom";
    enableGnomeExtension = true;
  };

  # Add the GNOME extension package to system packages
  environment.systemPackages = [
    jasper.packages.${pkgs.system}.gnome-extension
  ];
}