{
  description = "Tom's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { 
    self, 
    nixpkgs, 
    hyprland, 
    nixos-hardware
  }: {
    nixosConfigurations."gti" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.dell-xps-13-9370
        hyprland.nixosModules.default
        magic-nix-cache.nixosModules.default  # Added this line
        ./hosts/gti
      ];
    };
  };
}