{
  description = "TCass' NixOS Configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    hyprland.url = "github:hyprwm/Hyprland";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    eww.url = "github:elkowar/eww";
    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland";
    rust-overlay.url = "github:oxalica/rust-overlay";

    rust-overlay.inputs.nixpkgs.follows = "nixpkgs";
    eww.inputs.nixpkgs.follows = "nixpkgs";
    eww.inputs.rust-overlay.follows = "rust-overlay";
  };

  outputs = { self, nixpkgs, hyprland, nixos-hardware, eww-wayland, ... }@inputs :
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
          gtinix = nixpkgs.lib.nixosSystem {
            inherit system;

            modules = [
              ./hosts/gtinix/configuration.nix
              { _module.args = inputs; }
              {
                nixpkgs.overlays = [ hyprland.overlays.default];
              }
              hyprland.nixosModules.default
              {programs.hyprland.enable = true;}
              nixos-hardware.nixosModules.dell-xps-13-9370
              packages.system.eww-wayland
	    ];

            specialArgs = {
              inherit inputs;
            };
              
          };
        };
      };
}
