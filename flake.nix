{
  description = "Tom's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Add nixos-hardware
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, hyprland, nixos-hardware }: {
    nixosConfigurations."gti" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # Add XPS 13 9370 hardware configuration
        nixos-hardware.nixosModules.dell-xps-13-9370
        
        hyprland.nixosModules.default
        ./hosts/gti
      ];
    };
  };
}