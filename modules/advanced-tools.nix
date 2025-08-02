# Advanced NixOS ecosystem tools
{ config, pkgs, lib, ... }:

{
  # Advanced NixOS management tools
  environment.systemPackages = with pkgs; [
    # Remote deployment and installation
    nixos-anywhere
    
    # Fast Nix operations
    nix-fast-build
    
    # Disk partitioning (disko is used declaratively, not as a package)
    # disko is integrated via flake module when needed
    
    # Additional deployment and management tools
    nixos-generators    # Generate images for various platforms
    deploy-rs          # Alternative deployment tool
    colmena           # NixOS deployment tool
    
    # System inspection and debugging
    nix-tree          # Visualize Nix store dependencies
    nix-diff          # Compare Nix derivations
    nix-du            # Disk usage of Nix store paths
    nvd               # Nix version diff tool
    
    # Performance analysis
    hyperfine         # Command-line benchmarking tool
    flamegraph        # Generate flamegraphs from perf data
  ];

  # Enable experimental Nix features for advanced usage
  nix.settings = {
    # Already set in configuration.nix, but ensuring consistency
    experimental-features = [ "nix-command" "flakes" "repl-flake" ];
    
    # Optimize for parallel builds
    max-jobs = "auto";
    cores = 0; # Use all available cores
    
    # Better build output
    log-lines = 25;
    
    # Keep build logs for debugging
    keep-build-log = true;
  };

  # Aliases for advanced tools
  programs.fish.shellAliases = {
    # Fast build shortcuts
    fastbuild = "nix-fast-build";
    fb = "nix-fast-build";
    
    # Deployment shortcuts
    deploy = "nixos-rebuild switch --flake .#";
    deploy-remote = "nixos-anywhere";
    
    # System analysis
    nix-why = "nix-tree";
    nix-compare = "nix-diff";
    nix-size = "nix-du";
    
    # Performance testing
    bench = "hyperfine";
  };
}