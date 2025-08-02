# Disko configuration - Declarative disk partitioning
# This documents the current disk layout and enables automated installation
{ config, lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            # EFI System Partition
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            
            # Root partition (ext4)
            root = {
              size = "220.6G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
                mountOptions = [
                  "defaults"
                ];
              };
            };
            
            # Swap partition
            swap = {
              size = "16.9G";
              content = {
                type = "swap";
                discardPolicy = "both";
                resumeDevice = true; # Enable hibernation support
              };
            };
          };
        };
      };
    };
  };
  
  # Note: fileSystems and swapDevices are handled by hardware-configuration.nix
  # This disko configuration is for documentation and automated installation only
}