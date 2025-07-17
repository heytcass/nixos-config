# Dell Latitude 7280 - Secondary laptop configuration
# Host-specific settings for the transporter system

{
  hostname,
  ...
}:
{
  imports = [
    # Hardware configuration (auto-generated)
    ./hardware-configuration.nix
  ];

  # Host-specific configuration
  networking.hostName = hostname;

  # Dell Latitude 7280 specific optimizations
  # (Kernel parameters moved to hardware-configuration.nix for better organization)

  # Btrfs maintenance and snapshots for disko setup
  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
    fileSystems = [ "/" ];
  };
}
