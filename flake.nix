{
  description = "Tom's NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    
    # Add Hyprland
    hyprland.url = "github:hyprwm/Hyprland";
    # This ensures Hyprland uses the same nixpkgs as we do
    hyprland.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, hyprland }: {
    nixosConfigurations."gti" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        hyprland.nixosModules.default
        ./hosts/gti
      ];
    };
  };
}