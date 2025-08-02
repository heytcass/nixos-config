# Secure Boot configuration with lanzaboote
{ config, pkgs, lib, ... }:

{
  # Install sbctl for secure boot key management
  environment.systemPackages = with pkgs; [
    sbctl
  ];

  # Lanzaboote configuration for secure boot
  boot.lanzaboote = {
    enable = false; # Set to true after generating and enrolling keys
    pkiBundle = "/etc/secureboot";
  };

  # Disable systemd-boot when lanzaboote is enabled
  # boot.loader.systemd-boot.enable = lib.mkForce false;

  # TPM2 support for disk encryption
  boot.initrd = {
    # TPM2 tools for automatic LUKS unlock
    systemd.enable = true; # Already enabled in boot.nix
    availableKernelModules = [ "tpm_crb" "tpm_tis" ];
  };

  # Security settings for TPM2
  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
    abrmd.enable = false; # Use in-kernel resource manager
  };

  # Additional packages for TPM2 management
  environment.systemPackages = with pkgs; [
    tpm2-tss
    tpm2-tools
    tpm2-pkcs11
  ];
}