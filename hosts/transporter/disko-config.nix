# Disko configuration for Dell Latitude 7280 (transporter)
# Battle-tested configuration optimized for Dell Latitude 7280 hardware
# Based on proven working examples from the community

_: {
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda"; # Dell Latitude 7280 SATA SSD
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              name = "root";
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                  "/home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=home"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                  "/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=nix"
                      "compress=zstd:1"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                  "/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "subvol=persist"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                  "/var/log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=log"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                    ];
                  };
                  "/swap" = {
                    mountpoint = "/swap";
                    swap.swapfile.size = "16G"; # Adjust based on your RAM (16GB for 16GB system)
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
