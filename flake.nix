{
  description = "TCass' NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, hyprland, nixos-hardware, ... }@inputs :
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      lib = nixpkgs.lib;
    in
      {
        nixosConfigurations = {
          gtinix = lib.nixosSystem {
            inherit system;

            modules = [
              ./hosts/gtinix/configuration.nix
              {
                nixpkgs.overlays = [ hyprland.overlays.default];
              }
              hyprland.nixosModules.default
              {programs.hyprland.enable = true;}
              nixos-hardware.nixosModules.dell-xps-13-9370
            ];

            specialArgs = {
              inherit inputs;
            };
              
          };
        };
      };
}
