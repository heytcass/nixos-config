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
    { _module.args = { inherit notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor jasper; }; }
    ../../modules/tools.nix
    ../../modules/secrets.nix
    ../../modules/secure-boot.nix
    ../../modules/advanced-tools.nix
    ../../modules/oomd.nix
    ../../modules/jasper.nix
  ];
}