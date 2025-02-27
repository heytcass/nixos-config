{
  description = "Tom's NixOS configuration";

  inputs = {
    # Core dependencies
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs:
    let
      system = "x86_64-linux"; # Change if you're using a different architecture
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;
    in
    {
      nixosConfigurations = {
        # Using your actual hostname from your configuration
        gti = lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            # Your system configuration
            ./configuration.nix
            
            # Home Manager module
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tom = import ./home.nix;
            }
          ];
        };
      };
    };
}
