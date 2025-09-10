{ config, pkgs, lib, claude-desktop-linux-flake, sops-nix, nix-output-monitor, ... }:

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
    { _module.args = { inherit claude-desktop-linux-flake sops-nix nix-output-monitor; }; }
    ../../modules/tools.nix
    ../../modules/secrets.nix
    ../../modules/secure-boot.nix
    ../../modules/advanced-tools.nix
    ../../modules/oomd.nix
    ../../modules/zsa-voyager.nix
    ../../modules/kernel-level-keyboard-layouts.nix
  ];
}
