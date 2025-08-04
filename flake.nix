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
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, home-manager, notion-mac-flake, claude-desktop-linux-flake, sops-nix, nix-output-monitor, lanzaboote, disko }:
    flake-utils.lib.eachDefaultSystem (system: {
      # Development shell for system maintenance
      devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nixos-rebuild
          home-manager.packages.${system}.default
          nix-output-monitor.packages.${system}.default
        ];
      };

      # Installation apps
      apps = {
        install-transporter = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.writeShellScript "install-transporter" ''
            if [ -z "$1" ]; then
              echo "Usage: nix run .#install-transporter <target-host> [disk-device]"
              echo "Example: nix run .#install-transporter 192.168.1.100"
              exit 1
            fi
            
            TARGET_HOST="$1"
            DISK_DEVICE="''${2:-/dev/sda}"
            
            echo "Installing NixOS on Dell Latitude 7280 (transporter)"
            echo "Target: $TARGET_HOST"
            echo "Disk: $DISK_DEVICE"
            echo ""
            
            exec ${nixpkgs.legacyPackages.${system}.nix}/bin/nix run github:nix-community/nixos-anywhere -- \
              --flake .#transporter \
              --target-host "nixos@$TARGET_HOST" \
              --extra-files ${./secrets} \
              --disk-device "$DISK_DEVICE"
          ''}";
        };
      };
    }) // {
      nixosConfigurations.gti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit home-manager notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor lanzaboote disko; };
        modules = [
          ./configuration.nix
          nixos-hardware.nixosModules.dell-xps-13-9370
          sops-nix.nixosModules.sops
          lanzaboote.nixosModules.lanzaboote
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

      # Dell Latitude 7280 configuration (test/development system)
      nixosConfigurations.transporter = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit home-manager notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor lanzaboote disko; };
        modules = [
          ./transporter-configuration.nix
          nixos-hardware.nixosModules.dell-latitude-7280
          ./hardware/dell-latitude-7280.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./modules/disko.nix
          home-manager.nixosModules.home-manager
          {
            # Use btrfs filesystem for Latitude 7280
            mySystem.storage.filesystem = "btrfs";
            mySystem.storage.diskDevice = "/dev/sda";  # Latitude typically uses SATA
            mySystem.storage.swapSize = "4G";  # Smaller swap for 8GB system
            
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
