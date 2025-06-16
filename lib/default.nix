# Library functions for NixOS configuration
# Exports all helper functions for use in flake.nix

{ inputs, outputs, stateVersion }:

import ./helpers.nix { inherit inputs outputs stateVersion; }