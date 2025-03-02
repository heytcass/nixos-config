{
  description = "Tom's NixOS configuration";

  # -----------------------------------------------------------------------
  # Input sources: Where Nix should get dependencies
  # -----------------------------------------------------------------------
  inputs = {
    # Core package collections
    nixpkgs = {
      url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.761040.tar.gz";
    };
    
    # Latest unstable for cutting-edge packages
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/master";
    };
    
    # Home Manager - Manages user environments
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # Use the same nixpkgs as above
    };
    
    # Hardware-specific configurations
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };
    
    # Tools for generating NixOS configurations
    nixos-generators = {
      url = "https://flakehub.com/f/nix-community/nixos-generators/0.1.473.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # VSCode extensions registry
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # FlakeHub CLI - package registry management tool
    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/*";
    };
  };

  # -----------------------------------------------------------------------
  # Output configuration: System configurations exposed by this flake
  # -----------------------------------------------------------------------
  outputs = { 
    self, 
    nixpkgs, 
    nixpkgs-unstable, 
    home-manager, 
    nixos-hardware, 
    nixos-generators, 
    nix-vscode-extensions, 
    fh, 
    ... 
  }@inputs:
    let
      # System architecture
      system = "x86_64-linux";
      
      # Standard package set from the stable Nixpkgs
      pkgs = nixpkgs.legacyPackages.${system};
      
      # Configure unstable package set with allowUnfree enabled
      unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      
      # Import nixpkgs library functions
      lib = nixpkgs.lib;
    in
    {
      # Define NixOS system configurations
      nixosConfigurations = {
        # System configuration for hostname "gti"
        gti = lib.nixosSystem {
          inherit system;
          
          # Pass useful variables to all modules
          specialArgs = { inherit inputs unstable; };
          
          # List of configuration modules
          modules = [
            # Core system configuration
            ./configuration.nix
            
            # Hardware-specific configuration (Dell XPS 9370)
            nixos-hardware.nixosModules.dell-xps-13-9370
            
            # Home Manager configuration
            home-manager.nixosModules.home-manager
            {
              # Home Manager settings
              home-manager = {
                useGlobalPkgs = true;      # Use the same pkgs as NixOS
                useUserPackages = true;    # Install user packages system-wide
                backupFileExtension = "backup";  # Backup modified files
                extraSpecialArgs = { inherit unstable inputs; };  # Pass vars to home.nix
                users.tom = import ./home.nix;  # User-specific config
              };
            }
          ];
        };
      };
    };
}