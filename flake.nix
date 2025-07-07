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
      inputs.nixpkgs.follows = "nixpkgs"; # Critical: prevents version conflicts
    };

    # Ghostty terminal emulator
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    # Hyprland window manager
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland plugins
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    # Niri window manager
    niri = {
      url = "github:YaLTeR/niri";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Stylix for unified theming
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-hardware,
      disko,
      ...
    }@inputs:
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
          desktop = "hyprland";
          modules = [
            # Dell XPS 13 9370 hardware support
            nixos-hardware.nixosModules.dell-xps-13-9370
          ];
        };

        # Laptop without gaming (Dell Latitude 7280) - with disko
        transporter = helper.mkNixOS {
          hostname = "transporter";
          desktop = "niri";
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
            (_: {
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
          desktop = "hyprland";
        };
        "tom@transporter" = helper.mkHome {
          hostname = "transporter";
          username = "tom";
          desktop = "niri";
        };
      };

      # Development shells for working on the configuration
      devShells = helper.forAllSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = with nixpkgs.legacyPackages.${system}; [
            # Nix tools
            nixd
            nil

            # Formatting and linting tools
            nixfmt-rfc-style # Official Nix formatter (RFC 166)
            statix # Nix linter for best practices
            deadnix # Remove unused imports and bindings
            pre-commit # Git hooks for automated formatting

            # Secrets management tools
            sops
            age

            # Binary cache tools
            cachix

            # Rust utilities for testing
            uutils-coreutils
            uutils-findutils
            sudo-rs
          ];

          shellHook = ''
            echo "🔧 NixOS Configuration Development Shell"
            echo "📝 Formatting tools: nixfmt-rfc-style, statix, deadnix"
            echo "🔐 Secret tools: sops, age"
            echo "🚀 Language servers: nixd, nil"
            echo "📦 Binary cache: cachix"
            echo "🦀 Rust utilities: uutils-coreutils, uutils-findutils, sudo-rs"
            echo ""
            echo "💡 Quick commands:"
            echo "  nixfmt-rfc-style **/*.nix  # Format all Nix files"
            echo "  statix check .             # Check for issues"
            echo "  deadnix                    # Find dead code"
            echo "  pre-commit install         # Setup git hooks"
            echo ""
            echo "🧪 Testing Rust utilities:"
            echo "  uutils-cp, uutils-mv, etc. # Test uutils commands"
            echo "  sudo-rs --version          # Test sudo-rs"
          '';
        };
      });
    };
}
