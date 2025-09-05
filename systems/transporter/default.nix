# Configuration for Dell Latitude 7280 (transporter)
# Test/development system configuration

{ config, pkgs, lib, claude-desktop-linux-flake, sops-nix, nix-output-monitor, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../hardware/dell-latitude-7280.nix
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
    ../../modules/post-install.nix
    # Skip secure-boot.nix for test system
    ../../modules/advanced-tools.nix
    ../../modules/oomd.nix
  ];
}
