{ config, pkgs, lib, jasper, ... }:

{
  # Import jasper NixOS module
  imports = [
    jasper.nixosModules.default
  ];

  # Enable jasper companion service
  services.jasperCompanion = {
    enable = true;
    package = jasper.packages.${pkgs.system}.default;
    user = "tom";
    enableGnomeExtension = true;
    flakePackages = jasper.packages.${pkgs.system};
  };

  # The module will handle adding packages when enableGnomeExtension is true
  # But we need to override the gnome extension package reference
  nixpkgs.overlays = [
    (final: prev: {
      jasper-companion = jasper.packages.${pkgs.system}.default;
      jasper-companion-gnome-extension = jasper.packages.${pkgs.system}.gnome-extension;
    })
  ];
}