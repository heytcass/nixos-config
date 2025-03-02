{
  description = "Tom's NixOS configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.761040.tar.gz";
    
    # Latest unstable for newer packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hardware configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    
    # NixOS Generators
    nixos-generators = {
      url = "https://flakehub.com/f/nix-community/nixos-generators/0.1.473.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # VSCode extensions
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # FlakeHub CLI
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, nixos-generators, nix-vscode-extensions, fh, ... }@inputs:
    let
      system = "x86_64-linux"; # Change if you're using a different architecture
      pkgs = nixpkgs.legacyPackages.${system};
      # Configure unstable with allowUnfree enabled
      unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        # Using your actual hostname from your configuration
        gti = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs unstable; };
          modules = [
            # Your system configuration
            ./configuration.nix
            
            # Dell XPS 9370 hardware configuration
            nixos-hardware.nixosModules.dell-xps-13-9370
            
            # Home Manager module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";  # Add backup option
              home-manager.extraSpecialArgs = { inherit unstable inputs; };
              home-manager.users.tom = import ./home.nix;
            }
          ];
        };
      };
    };
}
