# Overlay system for package customizations and optimizations
# Provides modular overlays for different use cases

{ inputs, ... }:

{
  # Default overlay for all systems
  default = final: prev: {
    # Custom packages and overrides
    inherit (inputs.claude-desktop.packages.${final.system}) 
      claude-desktop-with-fhs;
  };
  
  # ISO-specific optimizations for smaller builds
  iso-optimizations = import ./iso-optimizations.nix;
  
  # Development-specific overlays (future expansion)
  development = final: prev: {
    # Development tool overrides can go here
  };
  
  # Performance optimizations (future expansion)
  performance = final: prev: {
    # Performance-focused package overrides
  };
}