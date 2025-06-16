# Overlay system for package optimizations
# Based on wimpysworld's approach to selective package optimization

{ inputs, ... }:

{
  # ISO-specific optimizations
  iso-optimizations = import ./iso-optimizations.nix;
}