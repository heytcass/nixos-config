# User configuration mixin
# Defines user accounts and user-specific packages

{
  config,
  pkgs,
  lib,
  username,
  isISO,
  ...
}:

{
  # Base user configuration
  users.users.${username} = {
    description = "Tom Cassady";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    isNormalUser = true;
    shell = pkgs.fish;

  }
  // lib.optionalAttrs isISO {
    # ISO-specific user configuration
    password = "nixos";
  }
  // lib.optionalAttrs (!isISO) {
    # Use encrypted password hash for real systems
    hashedPasswordFile = config.sops.secrets.user_password_hash.path;
  };
}
