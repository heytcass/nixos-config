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
        # Stylix for unified theming
        inputs.stylix.nixosModules.stylix
        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
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
            # Hyprland module is imported directly in home.nix
          };
        }
      ]
      ++ modules;
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
      modules = [
        ../home/tom/home.nix
        inputs.stylix.homeModules.stylix
        {
          nixpkgs.config.allowUnfree = true;
        }
      ];
    };

  # Utility for multi-platform support
  forAllSystems = inputs.nixpkgs.lib.genAttrs [
    "aarch64-linux"
    "x86_64-linux"
    "aarch64-darwin"
    "x86_64-darwin"
  ];


in
{
  # Export all helper functions
  inherit
    mkNixOS
    mkHome
    forAllSystems
    ;
  inherit
    isWorkstation
    isLaptop
    isISO
    ;
}
