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
        transporter = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            # Hardware support - essential for Dell Latitude 7280
            nixos-hardware.nixosModules.common-pc-laptop
            nixos-hardware.nixosModules.common-pc-laptop-ssd
            nixos-hardware.nixosModules.common-cpu-intel
            nixos-hardware.nixosModules.dell-latitude-7280
            
            # Disko module - must be imported before configuration
            disko.nixosModules.disko
            
            # System configurations
            ./nixos
            ./hosts/transporter/configuration.nix
            ./hosts/transporter/disko-config.nix
            
            # Home Manager integration
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.tom = import ./home/tom/home.nix;
              home-manager.extraSpecialArgs = { 
                inherit inputs outputs;
                hostname = "transporter";
                username = "tom";
              };
            }
            
            # Dell-specific optimizations
            {
              # Intel graphics and power management
              hardware.enableAllFirmware = true;
              hardware.cpu.intel.updateMicrocode = true;
              services.thermald.enable = true;
              services.power-profiles-daemon.enable = false; # Disabled for TLP
              
              # Kernel parameters for stability
              boot.kernelParams = [ "intel_iommu=off" ];
              
              # Btrfs maintenance and snapshots
              services.btrfs.autoScrub = {
                enable = true;
                interval = "monthly";
                fileSystems = [ "/" ];
              };

              # Automatic TRIM for SSD longevity
              services.fstrim.enable = true;

              # Laptop power optimization
              services.tlp = {
                enable = true;
                settings = {
                  CPU_SCALING_GOVERNOR_ON_AC = "performance";
                  CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
                  RUNTIME_PM_ON_AC = "on";
                  RUNTIME_PM_ON_BAT = "auto";
                };
              };

              # Dell-specific hardware support
              boot.initrd.kernelModules = [ "i915" ];  # Intel graphics
              hardware.graphics.enable = true;
              services.libinput.enable = true;  # Touchpad
            }
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