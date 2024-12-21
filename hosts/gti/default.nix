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
    ../../modules/vscode
    ../../modules/hyprland
  ];

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
      environment = "gnome";  # Changed from "gnome" to "hyprland"
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
        extraGroups = [ "networkmanager" "wheel" "dialout" ];
        shell = pkgs.fish;
      };
      locale.region = "en_US.UTF-8";
    };
    vscode = {
      enable = true;
      extensions = {
        base = true;
        editing = true;
        formatting = true;
        languages = true;
      };
      wayland.enable = true;
    };
    hyprland = {
      enable = true;
      monitors = [
        {
          name = "DP-3";    # Primary monitor
          resolution = "1920x1080@60";
          position = "0x393";
          scale = 1.0;
        }
        {
          name = "eDP-1";   # Laptop screen
          resolution = "1920x1080@60";
          position = "1920x1050";
          scale = 1.0;
        }
        {
          name = "DP-4";    # Vertical monitor
          resolution = "1920x1080@60";
          position = "3840x0";
          scale = 1.0;
          transform = "rotate-90";
        }
      ];
      theme.colors = {
        background = "rgb(1d1f21)";
        foreground = "rgb(c5c8c6)";
        accent = "rgb(81a2be)";
      };
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