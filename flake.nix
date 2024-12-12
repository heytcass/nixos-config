{
  description = "Tom's NixOS Configuration ❄️";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add nixos-needsreboot
    nixos-needsreboot = {
      url = "https://codeberg.org/Mynacol/nixos-needsreboot/archive/main.tar.gz";
    };
  };

  outputs = { 
    self, 
    nixpkgs, 
    hyprland, 
    nixos-hardware,
    lanzaboote,
    home-manager,
    nixos-needsreboot
  }: {
    nixosConfigurations."gti" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.dell-xps-13-9370
        hyprland.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
        ./hosts/gti
        
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.tom = import ./home/tom;
        }

        # Add activation script for nixos-needsreboot
        {
          system.activationScripts = {
            nixos-needsreboot = {
              supportsDryActivation = true;
              text = ''
                ${nixos-needsreboot.packages.x86_64-linux.default}/bin/nixos-needsreboot "$systemConfig" || true
              '';
            };
          };
        }
      ];
    };
  };
}