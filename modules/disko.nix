# Disko Configuration for Declarative Disk Partitioning
# Supports both ext4 (XPS) and btrfs (Latitude) filesystems

{ config, lib, pkgs, ... }:

with lib;

{
  options.mySystem.storage = {
    filesystem = mkOption {
      type = types.enum [ "ext4" "btrfs" ];
      default = "ext4";
      description = "Root filesystem type";
    };
    
    diskDevice = mkOption {
      type = types.str;
      default = "/dev/nvme0n1";
      description = "Primary disk device";
    };
    
    swapSize = mkOption {
      type = types.str;
      default = "8G";
      description = "Swap partition size";
    };
    
    enableCompression = mkOption {
      type = types.bool;
      default = true;
      description = "Enable filesystem compression (btrfs only)";
    };
  };

  config = mkMerge [
    # Common disk layout
    {
      disko.devices = {
        disk = {
          main = {
            type = "disk";
            device = config.mySystem.storage.diskDevice;
            content = {
              type = "gpt";
              partitions = {
                ESP = {
                  priority = 1;
                  name = "ESP";
                  start = "1M";
                  end = "512M";
                  type = "EF00";
                  content = {
                    type = "filesystem";
                    format = "vfat";
                    mountpoint = "/boot";
                    mountOptions = [ "fmask=0077" "dmask=0077" ];
                  };
                };
                swap = {
                  priority = 2;
                  size = config.mySystem.storage.swapSize;
                  content = {
                    type = "swap";
                  };
                };
                root = {
                  priority = 3;
                  size = "100%";
                  content = mkIf (config.mySystem.storage.filesystem == "ext4") {
                    type = "filesystem";
                    format = "ext4";
                    mountpoint = "/";
                  };
                };
              };
            };
          };
        };
      };
    }

    # Btrfs-specific configuration
    (mkIf (config.mySystem.storage.filesystem == "btrfs") {
      disko.devices.disk.main.content.partitions.root.content = {
        type = "btrfs";
        extraArgs = [ "-f" ];
        subvolumes = {
          "/rootfs" = {
            mountpoint = "/";
            mountOptions = [ "compress=zstd" "noatime" ];
          };
          "/home" = {
            mountpoint = "/home";
            mountOptions = [ "compress=zstd" ];
          };
          "/nix" = {
            mountpoint = "/nix";
            mountOptions = [ "compress=zstd" "noatime" ];
          };
          "/persist" = {
            mountpoint = "/persist";
            mountOptions = [ "compress=zstd" ];
          };
          "/snapshots" = {
            mountOptions = [ "compress=zstd" ];
          };
        };
      };
    })

    # Enable btrfs tools when using btrfs
    (mkIf (config.mySystem.storage.filesystem == "btrfs") {
      environment.systemPackages = with pkgs; [
        btrfs-progs
        compsize
      ];
      
      # Auto-scrub for data integrity
      services.btrfs.autoScrub = {
        enable = true;
        interval = "monthly";
        fileSystems = [ "/" ];
      };
    })
  ];
}