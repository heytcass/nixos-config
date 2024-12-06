{ config, pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ../../modules/audio
    ../../modules/boot
    ../../modules/network
    ../../modules/desktop
    ../../modules/users
    ../../modules/packages
    ../../modules/vscode.nix
  ];

  # Enable and configure modules
  modules = {
    audio.enable = true;
    boot = {
      enable = true;
      bootloader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    desktop = {
      enable = true;
      environment = "gnome";
      keyboard = {
        layout = "us";
        variant = "colemak";
      };
    };
    network = {
      enable = true;
      hostName = "gti";
      networkmanager.enable = true;
    };
    packages = {
      enable = true;
      gui.enable = true;
      wayland.enable = true;
    };
    users = {
      enable = true;
      mainUser = {
        name = "tom";
        realName = "Tom Cassady";
        extraGroups = [ "networkmanager" "wheel" ];
        packages = with pkgs; [
          # User-specific packages can go here
        ];
      };
      locale.region = "en_US.UTF-8";
    };
  };

  # Nix settings
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Core system settings
  time.timeZone = "America/Detroit";

  # Keep this value the same as it affects system state management
  system.stateVersion = "24.11";
}