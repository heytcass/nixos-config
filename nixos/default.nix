# Base NixOS configuration
# This file is imported by all NixOS systems and provides the foundation

{ config, lib, pkgs, inputs, outputs, hostname, username, isWorkstation, isLaptop, isISO, ... }:

{
  imports = [
    # Import base system configuration (converted from modules/common/base.nix)
    ./_mixins/services/base.nix
    
    # Import desktop configuration for non-ISO systems
    (lib.mkIf (!isISO) ./_mixins/desktop/gnome.nix)
    
    # Import development tools for all systems
    ./_mixins/features/development.nix
    
    # Import gaming features only for workstations
    (lib.mkIf isWorkstation ./_mixins/features/gaming.nix)
    
    # Import user configuration
    ./_mixins/services/users.nix
  ];

  # System state version - consistent across all hosts
  system.stateVersion = lib.mkDefault "25.05";
}