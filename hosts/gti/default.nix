{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/audio
    ../../modules/boot.nix
    ../../modules/network.nix
    ../../modules/desktop
    ../../modules/users.nix
    ../../modules/packages.nix
    ../../modules/vscode.nix
  ];

  modules = {
    audio.enable = true;
    desktop = {
      enable = true;
      environment = "gnome";
      keyboard = {
        layout = "us";
        variant = "colemak";
      };
    };
  };

  # Rest of your configuration remains the same...
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  time.timeZone = "America/Detroit";
  system.stateVersion = "24.11";
}