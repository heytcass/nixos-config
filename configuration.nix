{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/packages.nix
  ];

  # Core system settings
  time.timeZone = "America/Detroit";

  # Keep this value the same as it affects system state management
  system.stateVersion = "24.11";

  # Commented options kept for future reference
  # services.openssh.enable = true;
  # networking.firewall = {
  #   enable = true;
  #   allowedTCPPorts = [ ];
  #   allowedUDPPorts = [ ];
  # };
}
