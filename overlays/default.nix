# Overlay system for package customizations and optimizations
# Provides modular overlays for different use cases

{ inputs, ... }:

{
  # Default overlay for all systems
  default = final: _prev: {
    # Custom packages and overrides
    inherit (inputs.claude-desktop.packages.${final.system})
      claude-desktop-with-fhs
      ;
  };

  # ISO-specific optimizations for smaller builds
  iso-optimizations = import ./iso-optimizations.nix;
}
