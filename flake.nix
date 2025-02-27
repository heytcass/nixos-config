{
  description = "Tom's NixOS configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Latest unstable for newer packages
    nixpkgs-unstable.url = "github:nixos/nixpkgs/master";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Hardware configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, nixos-hardware, ... }@inputs:
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
              home-manager.extraSpecialArgs = { inherit unstable; };
              home-manager.users.tom = import ./home.nix;
            }
          ];
        };
      };
    };
}
