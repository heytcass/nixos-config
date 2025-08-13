{ config, pkgs, lib, notion-mac-flake, claude-desktop-linux-flake, sops-nix, nix-output-monitor, jasper, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hardware/dell-xps-13-9370.nix
    ../../modules/base.nix
    ../../modules/options.nix
    ../../modules/boot.nix
    ../../modules/hardware.nix
    ../../modules/desktop.nix
    ../../modules/networking.nix
    ../../modules/security.nix
    ../../modules/performance.nix
    ../../modules/systemd.nix
    { _module.args = { inherit notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor jasper ; }; }
    ../../modules/tools.nix
    ../../modules/secrets.nix
    ../../modules/secure-boot.nix
    ../../modules/advanced-tools.nix
    ../../modules/oomd.nix
    # Import Jasper unified module with auto-detection (temporarily disabled for CI)
    # jasper.nixosModules.unified
  ];

  # Overlay to add jasper packages to nixpkgs (temporarily disabled for CI)
  # nixpkgs.overlays = [
  #   (final: prev: {
  #     # Keep dev extension for development workflow
  #     jasper-gnome-extension-dev = jasper.packages.${prev.system}.gnome-extension-dev;
  #     # Use unified package as default
  #     jasper-companion-unified = jasper.packages.${prev.system}.default;
  #     # Individual components still available if needed
  #     jasper-companion = jasper.packages.${prev.system}.daemon;
  #     jasper-gnome-extension = jasper.packages.${prev.system}.gnome-extension;
  #   })
  # ];

  # Configure Jasper Companion with unified package (temporarily disabled for CI)
  # services.jasperCompanion = {
  #   enable = true;
  #   user = "tom";
  #   package = pkgs.jasper-companion-unified;
  #   
  #   # Enable automatic desktop environment detection
  #   autoDetectDesktop = true;
  #   
  #   # Optional: Force specific frontends (leave empty for auto-detection)
  #   # forceEnableFrontends = [ "gnome" "waybar" ];
  #   
  #   # Optional: Additional daemon configuration
  #   extraConfig = {
  #     # Custom environment variables can be added here if needed
  #   };
  # };
}