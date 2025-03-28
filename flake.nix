{
  description = "Tom's NixOS configuration";

  # -----------------------------------------------------------------------
  # Input sources: Where Nix should get dependencies
  # -----------------------------------------------------------------------
  inputs = {
    # Determinate Systems
    impermanence.url = "https://flakehub.com/f/nix-community/impermanence/0.1.179.tar.gz";
    determinate = {
      url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Claude Desktop
    claude-desktop = {
      url = "github:k3d3/claude-desktop-linux-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    
    # FlakeHub CLI - package registry management tool
    fh = {
      url = "https://flakehub.com/f/DeterminateSystems/fh/*";
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
    
    # NixOS Needs Reboot - Tool to notify of required reboots
    nixos-needsreboot = {
      url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/0.2.5.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Core package collections
    nixpkgs = {
      url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.761040.tar.gz";
    };
    
    # Latest unstable for cutting-edge packages
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/master";
    };
    
    # Flake Utils - Common utilities for flake-based projects
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    
    # VSCode extensions registry
    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # -----------------------------------------------------------------------
  # Output configuration: System configurations exposed by this flake
  # -----------------------------------------------------------------------
  outputs = { 
    self, 
    claude-desktop,
    determinate,
    fh,
    flake-utils,
    home-manager,
    nix-vscode-extensions,
    nixos-generators,
    nixos-hardware,
    nixos-needsreboot,
    nixpkgs, 
    nixpkgs-unstable, impermanence, 
    ... 
  }@inputs:
    let
      # System architecture
      system = "x86_64-linux";
      
      # Configure unstable package set with allowUnfree enabled
      unstable = import nixpkgs-unstable {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };
      
      # Import nixpkgs library functions
      lib = nixpkgs.lib;
      
      # NixOS Needs Reboot package module
      # Note: The activation script is already defined in hosts/common/default.nix
      needsRebootModule = { pkgs, ... }: {
        imports = [];
        config = { 
          environment.systemPackages = [ nixos-needsreboot.packages.x86_64-linux.default ];
        };
      };
    in
    {
      # Define NixOS system configurations
      nixosConfigurations = {
        # System configuration for hostname "gti" - Dell XPS 13-9370 with GNOME
        gti = lib.nixosSystem {
          inherit system;
          
          # Pass useful variables to all modules
          specialArgs = { inherit inputs unstable; };
          
          # List of configuration modules
          modules = [
            # Common configuration
            ./hosts/common
            
            # Host-specific configuration
            ./hosts/gti
            
            # Hardware-specific configuration (Dell XPS 9370)
            nixos-hardware.nixosModules.dell-xps-13-9370
            
            # Determinate Nix module
            inputs.determinate.nixosModules.default
            
            # NixOS Needs Reboot notification imported via common module
            
            # Home Manager configuration
            home-manager.nixosModules.home-manager
            {
              # Home Manager settings
              home-manager = {
                useGlobalPkgs = true;      # Use the same pkgs as NixOS
                useUserPackages = true;    # Install user packages system-wide
                backupFileExtension = "backup";  # Backup modified files
                extraSpecialArgs = { inherit unstable inputs; };  # Pass vars to home.nix
                users.tom = import ./hosts/common/users/tom.nix;  # User-specific config
              };
            }
          ];
        };
        
        # System configuration for hostname "transporter" - Dell Latitude 7280 with Hyprland
        transporter = lib.nixosSystem {
          inherit system;
          
          # Pass useful variables to all modules
          specialArgs = { inherit inputs unstable; };
          
          # List of configuration modules
          modules = [
            # Common configuration
            ./hosts/common
            
            # Host-specific configuration
            ./hosts/transporter
            
            # Hardware-specific configuration (Dell Latitude 7280)
            nixos-hardware.nixosModules.dell-latitude-7280
            
            # Determinate Nix module
            inputs.determinate.nixosModules.default
            
            # NixOS Needs Reboot notification imported via common module
            
            # Home Manager configuration
            home-manager.nixosModules.home-manager
            {
              # Home Manager settings
              home-manager = {
                useGlobalPkgs = true;      # Use the same pkgs as NixOS
                useUserPackages = true;    # Install user packages system-wide
                backupFileExtension = "backup";  # Backup modified files
                extraSpecialArgs = { inherit unstable inputs; };  # Pass vars to home.nix
                users.tom = import ./hosts/common/users/tom.nix;  # User-specific config
              };
            }
          ];
        };
      };
      
      # Custom installation ISOs with your personal environment and configuration
      packages.x86_64-linux = {
        # Basic installation ISO with minimal environment
        install-iso-basic = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "install-iso";
          modules = [
            ({ pkgs, lib, ... }: {
              isoImage.edition = "nixos-config";
              
              # Include Git for cloning the repo during installation
              environment.systemPackages = with pkgs; [ 
                git 
                vim
                wget
                gparted
                parted
              ];
              
              # Create a placeholder for the installation script
              system.activationScripts.installation-script = lib.stringAfter [ "users" ] ''
                cp ${./install.sh} /root/
                chmod +x /root/install.sh
              '';
            })
          ];
        };
        
        # Full installation ISO with your custom environment
        install-iso-custom = nixos-generators.nixosGenerate {
          system = "x86_64-linux";
          format = "install-iso";
          modules = [
            ./hosts/installer
          ];
        };
      };
    };
}