# Dell XPS 13 9370 - Main workstation configuration
# Host-specific settings for the gti system

{
  config,
  pkgs,
  inputs,
  hostname,
  username,
  ...
}: {
  imports = [
    # Hardware configuration (auto-generated)
    ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = hostname;
  
  # Host-specific overrides can go here
  # Most configuration is now handled by the mixin system
}