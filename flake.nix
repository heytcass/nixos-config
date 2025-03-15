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
      
      # Add NixOS Needs Reboot to any configuration
      needsRebootModule = { pkgs, ... }: {
        imports = [];
        config = { 
          environment.systemPackages = [ nixos-needsreboot.packages.x86_64-linux.default ];
          system.activationScripts.nixos-needsreboot = {
            text = ''
              echo "Checking if reboot is needed..."
              ${nixos-needsreboot.packages.x86_64-linux.default}/bin/nixos-needsreboot || true
            '';
            deps = [];
          };
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
            
            # NixOS Needs Reboot notification
            needsRebootModule
            
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
            
            # NixOS Needs Reboot notification
            needsRebootModule
            
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
      
      # Installation ISO with the configuration files for both hosts
      packages.x86_64-linux.install-iso = nixos-generators.nixosGenerate {
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
              cat > /root/install.sh << 'EOF'
#!/usr/bin/env bash
set -e

# Check for hostname argument
if [ $# -ne 1 ]; then
  echo "Usage: $0 [gti|transporter]"
  exit 1
fi

HOSTNAME=$1
if [ "$HOSTNAME" != "gti" ] && [ "$HOSTNAME" != "transporter" ]; then
  echo "Error: Hostname must be either 'gti' or 'transporter'"
  exit 1
fi

echo "Installing NixOS on $HOSTNAME..."

# This is where you would add the disk partitioning commands
# Example for a basic EFI setup:
#
# DISK=/dev/nvme0n1  # Change this to match your actual disk
# parted "$DISK" -- mklabel gpt
# parted "$DISK" -- mkpart ESP fat32 1MiB 512MiB
# parted "$DISK" -- set 1 boot on
# parted "$DISK" -- mkpart primary 512MiB 100%
# 
# mkfs.fat -F 32 -n boot "$DISK"p1
# mkfs.ext4 -L nixos "$DISK"p2
#
# mount "$DISK"p2 /mnt
# mkdir -p /mnt/boot
# mount "$DISK"p1 /mnt/boot

# Clone the NixOS config repository
mkdir -p /mnt/home/tom
git clone https://github.com/yourusername/nixos-config /mnt/home/tom/.nixos-config

# Install NixOS with the specified hostname configuration
nixos-install --flake /mnt/home/tom/.nixos-config#$HOSTNAME

echo "Installation complete! You can now reboot into your new system."
EOF
              chmod +x /root/install.sh
            '';
          })
        ];
      };
    };
}