# Helper functions for NixOS system generation
# Inspired by wimpysworld's approach with DRY principles

{
  inputs,
  outputs,
  stateVersion,
}:

let
  inherit (inputs.nixpkgs) lib;

  # System type detection helpers
  isWorkstation = hostname: lib.hasInfix "gti" hostname;
  isLaptop = hostname: lib.hasInfix "transporter" hostname;
  isISO = hostname: hostname == "iso";

  # Helper to dynamically import all modules in a directory
  importDirectory =
    path:
    let
      entries = builtins.readDir path;
      nixFiles = lib.filterAttrs (
        name: type: type == "regular" && lib.hasSuffix ".nix" name && name != "default.nix"
      ) entries;
      importPath = name: path + "/${name}";
    in
    map importPath (lib.attrNames nixFiles);

  # Create NixOS system configuration with consistent patterns
  mkNixOS =
    {
      hostname,
      username ? "tom",
      desktop ? "gnome",
      platform ? "x86_64-linux",
      modules ? [ ],
    }:
    inputs.nixpkgs.lib.nixosSystem {
      system = platform;
      specialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          username
          stateVersion
          ;
        # System type flags for conditional configuration
        isWorkstation = isWorkstation hostname;
        isLaptop = isLaptop hostname;
        isISO = isISO hostname;
      };
      modules = [
        # Base system configuration will be in nixos/
        ../nixos
        # Host-specific configuration
        ../hosts/${hostname}/configuration.nix
        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${username} = import ../home/tom/home.nix;
            extraSpecialArgs = {
              inherit
                inputs
                outputs
                desktop
                hostname
                username
                ;
              isWorkstation = isWorkstation hostname;
              isLaptop = isLaptop hostname;
              isISO = isISO hostname;
            };
          };
        }
      ] ++ modules;
    };

  # Create Home Manager configuration
  mkHome =
    {
      hostname,
      username,
      desktop ? "gnome",
      platform ? "x86_64-linux",
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = inputs.nixpkgs.legacyPackages.${platform};
      extraSpecialArgs = {
        inherit
          inputs
          outputs
          desktop
          hostname
          username
          ;
        isWorkstation = isWorkstation hostname;
        isLaptop = isLaptop hostname;
        isISO = isISO hostname;
      };
      modules = [ ../home/tom/home.nix ];
    };

  # Utility for multi-platform support
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];

  # Package utilities for conditional inclusion
  optionalPackages = condition: packages: if condition then packages else [ ];

  # Create package set with overlays
  mkPkgs =
    platform:
    import inputs.nixpkgs {
      system = platform;
      overlays = [ outputs.overlays.default or (_final: _prev: { }) ];
      config.allowUnfree = true;
    };

in
{
  # Export all helper functions
  inherit
    mkNixOS
    mkHome
    forAllSystems
    importDirectory
    ;
  inherit
    isWorkstation
    isLaptop
    isISO
    optionalPackages
    mkPkgs
    ;
}
