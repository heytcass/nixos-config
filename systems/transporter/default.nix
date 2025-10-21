# Configuration for Dell Latitude 7280 (transporter)
# Test/development system configuration

{ config, pkgs, lib, claude-desktop-linux-flake, sops-nix, nix-output-monitor, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hardware/dell-latitude-7280.nix
  ] ++ (import ../../modules/common-imports.nix { inherit claude-desktop-linux-flake sops-nix nix-output-monitor; }) ++ [
    # System-specific modules
    ../../modules/post-install.nix
    # Skip secure-boot.nix for test system
  ];
}
