{
  description = "Tom's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    notion-mac-flake = {
      url = "github:heytcass/notion-mac-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    claude-desktop-linux-flake = {
      url = "github:heytcass/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-output-monitor = {
      url = "github:maralorn/nix-output-monitor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, home-manager, notion-mac-flake, claude-desktop-linux-flake, sops-nix, nix-output-monitor, lanzaboote, disko, impermanence }:
    flake-utils.lib.eachDefaultSystem (system: {
      # Development shell for system maintenance
      devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nixos-rebuild
          home-manager.packages.${system}.default
          nix-output-monitor.packages.${system}.default
        ];
      };
    }) // {
      nixosConfigurations.gti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit home-manager notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor lanzaboote disko impermanence; };
        modules = [
          ./configuration.nix
          nixos-hardware.nixosModules.dell-xps-13-9370
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
          disko.nixosModules.disko
          impermanence.nixosModules.impermanence
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.sharedModules = [
              sops-nix.homeManagerModules.sops
            ];
            home-manager.users.tom = import ./home.nix;
          }
        ];
      };
    };
}
