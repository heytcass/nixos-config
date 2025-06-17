# User configuration mixin
# Defines user accounts and user-specific packages

{ config, pkgs, lib, username, isISO, ... }:

{
  # Base user configuration
  users.users.${username} = {
    description = "Tom Cassady";
    extraGroups = [ "networkmanager" "wheel" "dialout" ];
    isNormalUser = true;
    shell = pkgs.fish;
    
    # User packages - only for non-ISO systems
    packages = lib.optionals (!isISO) (with pkgs; [
      # Common applications for both laptops
      apostrophe
      bitwarden-desktop
      boatswain
      claude-code
      discord
      google-chrome
      slack
      spotify
      todoist-electron
      zoom-us
    ]);
  } // lib.optionalAttrs isISO {
    # ISO-specific user configuration
    password = "nixos";
  } // lib.optionalAttrs (!isISO) {
    # Use encrypted password hash for real systems
    hashedPasswordFile = config.sops.secrets.user_password_hash.path;
  };
}