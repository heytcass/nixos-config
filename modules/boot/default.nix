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
      systemd-boot.enable = config.modules.boot.bootloader.systemd-boot.enable;
      efi.canTouchEfiVariables = config.modules.boot.bootloader.efi.canTouchEfiVariables;
    };
  };
}