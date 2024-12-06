{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/boot.nix
    ../../modules/network.nix
    ../../modules/desktop.nix
    ../../modules/audio.nix
    ../../modules/users.nix
    ../../modules/packages.nix
    ../../modules/vscode.nix
  ];

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Core system settings
  time.timeZone = "America/Detroit";

  # Keep this value the same as it affects system state management
  system.stateVersion = "24.11";
}