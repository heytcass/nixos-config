# Dell Latitude 7280 - Secondary laptop configuration  
# Host-specific settings for the transporter system

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
  # Gaming module is automatically excluded for non-workstation systems
  # Most configuration is now handled by the mixin system
}