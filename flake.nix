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
    jasper = {
      url = "path:/home/tom/projects/jasper";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, flake-utils, home-manager, notion-mac-flake, claude-desktop-linux-flake, sops-nix, nix-output-monitor, lanzaboote, disko, jasper }:
    flake-utils.lib.eachDefaultSystem (system: {
      # Development shell for system maintenance
      devShells.default = nixpkgs.legacyPackages.${system}.mkShell {
        buildInputs = with nixpkgs.legacyPackages.${system}; [
          nixos-rebuild
          home-manager.packages.${system}.default
        ] ++ nixpkgs.lib.optionals (!nixpkgs.legacyPackages.${system}.stdenv.isDarwin) [
          # nix-output-monitor has issues in CI environments, only include locally
          # Uncomment below line if you want nom in devShell locally
          # nix-output-monitor.packages.${system}.default
        ];
      };

      # Installation apps
      apps = {
        install-transporter = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.writeShellScript "install-transporter" ''
            if [ -z "$1" ]; then
              echo "Usage: nix run .#install-transporter <target-host> [disk-device]"
              echo "Examples:"
              echo "  nix run .#install-transporter 192.168.1.100"
              echo "  nix run .#install-transporter 192.168.1.100 /dev/nvme0n1"
              echo ""
              echo "Common Dell Latitude 7280 disk devices:"
              echo "  /dev/sda     - SATA M.2 SSD (default)"
              echo "  /dev/nvme0n1 - NVMe M.2 SSD"
              exit 1
            fi
            
            TARGET_HOST="$1"
            DISK_DEVICE="''${2:-/dev/sda}"
            
            echo "🚀 Installing NixOS on Dell Latitude 7280 (transporter)"
            echo "Target: $TARGET_HOST"
            echo "Disk: $DISK_DEVICE"
            echo "Features: btrfs, post-install automation, professional A/V setup"
            echo ""
            
            # Create temporary flake override if custom disk device specified
            if [ "$DISK_DEVICE" != "/dev/sda" ]; then
              echo "⚙️  Creating temporary configuration for $DISK_DEVICE..."
              TEMP_DIR=$(mktemp -d)
              cp -r . "$TEMP_DIR/"
              cd "$TEMP_DIR"
              
              # Override disk device in flake
              sed -i "s|mySystem.storage.diskDevice = \"/dev/sda\"|mySystem.storage.diskDevice = \"$DISK_DEVICE\"|" flake.nix
              
              # Run installation from temp directory
              FLAKE_DIR="$TEMP_DIR"
            else
              FLAKE_DIR="."
            fi
            
            # Run nixos-anywhere installation
            if ${nixpkgs.legacyPackages.${system}.nix}/bin/nix run github:nix-community/nixos-anywhere -- \
              --flake "$FLAKE_DIR#transporter" \
              --target-host "nixos@$TARGET_HOST" \
              --extra-files ${./secrets}; then
              
              echo ""
              echo "✅ Installation completed successfully!"
              echo ""
              echo "🔄 System is rebooting with post-install automation enabled"
              echo "📋 After reboot, the system will automatically:"
              echo "   • Validate age key configuration for secrets"
              echo "   • Prepare YubiKey FIDO2/U2F directories"
              echo "   • Verify all essential services"
              echo "   • Show setup completion status"
              echo ""
              echo "🔑 Manual steps after reboot (SSH to tom@$TARGET_HOST):"
              echo "   • YubiKey PIV: ykman piv keys generate 9a /tmp/pubkey.pem"
              echo "   • Add SSH key to GitHub: ssh-add -L (from YubiKey agent)"
              echo "   • Test A/V: launch 'obs' and 'easyeffects'"
              echo ""
              echo "🎉 Dell Latitude 7280 'transporter' is ready!"
              
              # Clean up temp directory if used
              if [ "$DISK_DEVICE" != "/dev/sda" ] && [ -n "$TEMP_DIR" ]; then
                rm -rf "$TEMP_DIR"
              fi
            else
              echo "❌ Installation failed - check output above for details"
              
              # Clean up temp directory if used
              if [ "$DISK_DEVICE" != "/dev/sda" ] && [ -n "$TEMP_DIR" ]; then
                rm -rf "$TEMP_DIR"
              fi
              exit 1
            fi
          ''}";
        };
        
        # Convenience app for post-install steps
        setup-yubikey-piv = {
          type = "app";
          program = "${nixpkgs.legacyPackages.${system}.writeShellScript "setup-yubikey-piv" ''
            echo "🔑 YubiKey PIV SSH Setup"
            echo "This will generate a new ECCP256 key in PIV slot 9a"
            echo ""
            
            if ! ${nixpkgs.legacyPackages.${system}.yubikey-manager}/bin/ykman list >/dev/null 2>&1; then
              echo "❌ No YubiKey detected. Please insert YubiKey and try again."
              exit 1
            fi
            
            echo "Generating PIV key in slot 9a..."
            ${nixpkgs.legacyPackages.${system}.yubikey-manager}/bin/ykman piv keys generate 9a /tmp/pubkey.pem
            ${nixpkgs.legacyPackages.${system}.yubikey-manager}/bin/ykman piv certificates generate 9a /tmp/pubkey.pem
            
            echo ""
            echo "✅ PIV key generated successfully!"
            echo "🔄 Restarting yubikey-agent..."
            systemctl --user restart yubikey-agent
            
            echo ""
            echo "📋 Your SSH public key (add to GitHub/GitLab):"
            SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock" ${nixpkgs.legacyPackages.${system}.openssh}/bin/ssh-add -L
            echo ""
            echo "🧪 Test GitHub authentication:"
            echo "SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/yubikey-agent/yubikey-agent.sock\" ssh -T git@github.com"
          ''}";
        };
      };
    }) // {
      nixosConfigurations.gti = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit home-manager notion-mac-flake claude-desktop-linux-flake sops-nix nix-output-monitor lanzaboote disko jasper; };
        modules = [
          ./systems/gti
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
          ./systems/transporter
          nixos-hardware.nixosModules.dell-latitude-7280
          ./hardware/dell-latitude-7280.nix
          sops-nix.nixosModules.sops
          disko.nixosModules.disko
          ./modules/disko.nix
          home-manager.nixosModules.home-manager
          {
            # Use btrfs filesystem for Latitude 7280
            mySystem.storage.filesystem = "btrfs";
            mySystem.storage.diskDevice = "/dev/sda";  # Default SATA; use /dev/nvme0n1 for NVMe
            mySystem.storage.swapSize = "4G";  # Smaller swap for 8GB system
            
            # Enable post-installation automation
            mySystem.postInstall.enable = true;
            
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
