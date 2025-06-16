{
  description = "Tom's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # NixOS Hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    
    # Claude Desktop
    claude-desktop = {
      url = "github:heytcass/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, claude-desktop, ... }@inputs: {
    nixosConfigurations = {
      gti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/gti/configuration.nix
          
          # Add Home Manager module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tom = import ./home/tom/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      
      transporter = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/transporter/configuration.nix
          
          # Add Home Manager module
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.tom = import ./home/tom/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs; };
          }
        ];
      };
      
      # Live ISO configuration
      iso = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/iso/configuration.nix
          # Apply ISO-specific overlays
          ({ config, lib, pkgs, ... }: {
            nixpkgs.overlays = [
              (import ./overlays { inherit inputs; }).iso-optimizations
            ];
          })
        ];
      };
    };
  };
}