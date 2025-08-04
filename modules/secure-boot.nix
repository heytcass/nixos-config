# Secure Boot configuration with lanzaboote
{ config, pkgs, lib, ... }:

{
  # Lanzaboote configuration for secure boot
  boot.lanzaboote = {
    enable = true; # Re-enabled after successful rebuild
    pkiBundle = "/etc/secureboot";
  };

  # Re-enable systemd-boot when lanzaboote is disabled
  boot.loader.systemd-boot.enable = lib.mkForce (!config.boot.lanzaboote.enable);

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

  # Secure boot and TPM2 management packages
  environment.systemPackages = with pkgs; [
    # Secure boot tools
    sbctl
    
    # TPM2 tools
    tpm2-tss
    tpm2-tools
    tpm2-pkcs11
  ];
}