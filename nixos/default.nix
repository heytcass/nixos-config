# Base NixOS configuration
# This file is imported by all NixOS systems and provides the foundation

{ config, lib, pkgs, inputs, outputs, hostname, username, isWorkstation, isLaptop, isISO, ... }:

{
  imports = [
    # Import base system configuration (converted from modules/common/base.nix)
    ./_mixins/services/base.nix
    
    # Import development tools for all systems
    ./_mixins/features/development.nix
    
    # Import user configuration
    ./_mixins/services/users.nix
    
    # Import secrets management
    ./_mixins/services/secrets.nix
  ] ++ lib.optionals (!isISO) [
    # Import desktop configuration for non-ISO systems
    ./_mixins/desktop/gnome.nix
  ] ++ lib.optionals isWorkstation [
    # Import gaming features only for workstations
    ./_mixins/features/gaming.nix
  ];

  # System state version - consistent across all hosts (but let ISO override)
  system.stateVersion = lib.mkIf (!isISO) "25.05";
}