{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.boot = {
    enable = mkEnableOption "boot configuration";

    bootloader = {
      systemd-boot = {
        enable = mkEnableOption "systemd-boot";
      };
      
      efi = {
        canTouchEfiVariables = mkOption {
          type = types.bool;
          default = true;
          description = "Whether the EFI variables can be modified";
        };
      };
    };
  };

  config = mkIf config.modules.boot.enable {
    boot.loader = {
      systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = config.modules.boot.bootloader.efi.canTouchEfiVariables;
    };

    # Add lanzaboote configuration
    boot.lanzaboote = {
      enable = true;
      pkiBundle = "/etc/secureboot";
    };

    # Add proper resume support
    boot.resumeDevice = "/dev/nvme0n1p3";
    boot.kernelParams = [
      "mem_sleep_default=deep"  # Force deep sleep mode
      "nvme.noacpi=1"          # Help with NVME suspend issues
      "acpi_rev_override=1"    # Fix potential ACPI issues
      "acpi_sleep=deep"        # Additional parameter to enforce deep sleep
    ];
    boot.initrd.supportedFilesystems = [ "encrypt" "ext4" ];

    # Add sbctl for debugging secure boot
    environment.systemPackages = [ pkgs.sbctl ];
  };
}