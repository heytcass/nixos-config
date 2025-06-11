{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ../../modules/common/base.nix
    ../../modules/common/desktop.nix
    ../../modules/common/development.nix
    ../../modules/common/users.nix
    inputs.nixos-hardware.nixosModules.dell-latitude-7280
    # Gaming module is optional - uncomment if needed
    # ../../modules/common/gaming.nix
  ];

  # Host-specific configuration
  networking.hostName = "transporter";

  system.stateVersion = "25.05";
}