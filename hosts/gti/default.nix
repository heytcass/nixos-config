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
        shell = pkgs.fish;  # Set fish as default shell
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
      enable = false;  # Set to true when ready to switch
      monitors = [
        {
          name = "eDP-1";    # Adjust these for your monitor
          resolution = "1920x1080@60";
          position = "0x0";
          scale = 1.0;
        }
      ];
      wallpaper = {
        enable = false;      # Enable when you have a wallpaper ready
        path = "";          # Add your wallpaper path when ready
      };
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