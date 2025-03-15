# Custom installation ISO configuration
# This creates an ISO that mirrors your personal environment
{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    # Base installer module
    "${modulesPath}/installer/cd-dvd/installation-cd-graphical-calamares.nix"
    
    # Common modules - include your desktop configuration
    ../common/optional/gnome.nix
  ];

  # Use the same hostname as your personal machine temporarily
  networking.hostName = "nixos-installer";

  # Include your core packages
  environment.systemPackages = with pkgs; [
    # Installation tools
    git
    vim
    wget
    gparted
    parted
    
    # Your personal favorite applications
    ghostty
    bitwarden-desktop
    google-chrome
    ripgrep
    bat
    eza
    fd
    bottom
    
    # Add other packages you want available during installation
  ];

  # Set up your preferred keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak";
  };

  # Enable your preferred shell environment
  programs.bash = {
    enableCompletion = true;
    interactiveShellInit = ''
      # Add your custom bash settings here
      alias ls='eza --icons'
      alias cat='bat --paging=never'
      alias grep='rg'
      alias find='fd'
    '';
  };
  
  # Copy your installation script to the root directory
  system.activationScripts.installationScript = lib.stringAfter [ "users" ] ''
    cp ${../..}/install.sh /root/
    chmod +x /root/install.sh
  '';

  # Set up auto-login to the graphical environment
  services.xserver.displayManager.autoLogin = {
    enable = true;
    user = "nixos";
  };

  # Include your personal fonts
  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
  ];

  # Increase the installer disk image size to accommodate your environment
  isoImage.volumeID = "NIXOS_CUSTOM";
  isoImage.isoName = "nixos-custom-installer.iso";
  isoImage.makeEfiBootable = true;
  isoImage.makeUsbBootable = true;
  isoImage.appendToMenuLabel = " Custom Installer";
}