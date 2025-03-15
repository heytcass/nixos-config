# Host-specific configuration for gti (Dell XPS 13-9370)
{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware.nix
    ../common/optional/gnome.nix
    # Hyprland not enabled on gti
  ];

  # Host-specific settings
  networking.hostName = "gti";
  
  # Host-specific packages
  environment.systemPackages = with pkgs; [
    # Add any packages specific to this machine
  ];
}