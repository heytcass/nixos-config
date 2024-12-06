{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/audio
    ../../modules/boot.nix
    ../../modules/network.nix
    ../../modules/desktop.nix
    ../../modules/users.nix
    ../../modules/packages.nix
    ../../modules/vscode.nix
  ];

  # Enable the audio module
  modules.audio.enable = true;

  # Rest of your configuration remains the same...
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  time.timeZone = "America/Detroit";
  system.stateVersion = "24.11";
}