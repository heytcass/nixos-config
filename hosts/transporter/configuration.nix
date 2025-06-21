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
  
  # Dell Latitude 7280 specific optimizations
  # Override base Intel IOMMU setting for stability on this hardware
  boot.kernelParams = [ "intel_iommu=off" ];
  
  # Btrfs maintenance and snapshots for disko setup
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}