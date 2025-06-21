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
    
    # SOPS for secrets management (foundation for future use)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Disko for declarative disk partitioning
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";  # Critical: prevents version conflicts
    };
    
    # Ghostty terminal emulator
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, claude-desktop, sops-nix, disko, ghostty, ... }@inputs:
    let
      inherit (self) outputs;
      stateVersion = "25.05";
      
      # Import our helper functions
      helper = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # Overlays for package customizations
      overlays = import ./overlays { inherit inputs; };
      
      # NixOS configurations using helper functions
      nixosConfigurations = {
        # Workstation with gaming (Dell XPS 13 9370)
        gti = helper.mkNixOS {
          hostname = "gti";
          desktop = "gnome";
          modules = [
            # Dell XPS 13 9370 hardware support
            nixos-hardware.nixosModules.dell-xps-13-9370
          ];
        };
        
        # Laptop without gaming (Dell Latitude 7280) - with disko
        transporter = helper.mkNixOS {
          hostname = "transporter";
          desktop = "gnome";
          modules = [
            # Dell Latitude 7280 hardware support
            nixos-hardware.nixosModules.dell-latitude-7280
            
            # Disko module - must be imported before configuration
            disko.nixosModules.disko
            ./hosts/transporter/disko-config.nix
          ];
        };
        
        # Live ISO configuration
        iso = helper.mkNixOS {
          hostname = "iso";
          modules = [
            # Apply ISO-specific overlays
            ({ config, lib, pkgs, ... }: {
              nixpkgs.overlays = [ outputs.overlays.iso-optimizations ];
            })
          ];
        };
      };
      
      # Home Manager configurations (for potential standalone use)
      homeConfigurations = {
        "tom@gti" = helper.mkHome {
          hostname = "gti";
          username = "tom";
          desktop = "gnome";
        };
        "tom@transporter" = helper.mkHome {
          hostname = "transporter";
          username = "tom";
          desktop = "gnome";
        };
      };
      
      # Development shells for working on the configuration
      devShells = helper.forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            # Nix tools
            nixd
            nil
            statix
            deadnix
            
            # Future: SOPS tools for secrets management
            sops
            age
          ];
          
          shellHook = ''
            echo "NixOS Configuration Development Shell"
            echo "Available tools: nixd, nil, statix, deadnix, sops, age"
          '';
        };
      });
    };
}