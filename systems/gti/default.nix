{ config, pkgs, lib, claude-desktop-linux-flake, sops-nix, nix-output-monitor, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hardware/dell-xps-13-9370.nix
  ] ++ (import ../../modules/common-imports.nix { inherit claude-desktop-linux-flake sops-nix nix-output-monitor; }) ++ [
    # System-specific modules
    ../../modules/fonts.nix
    ../../modules/secure-boot.nix
    ../../modules/zsa-voyager.nix
    ../../modules/kernel-level-keyboard-layouts.nix
  ];
}
