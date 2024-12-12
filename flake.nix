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

    # Add home-manager as a new input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self, 
    nixpkgs, 
    hyprland, 
    nixos-hardware,
    lanzaboote,
    home-manager
  }: {
    nixosConfigurations."gti" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nixos-hardware.nixosModules.dell-xps-13-9370
        hyprland.nixosModules.default
        lanzaboote.nixosModules.lanzaboote
        ./hosts/gti
        
        # Add home-manager as NixOS module
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.tom = import ./home/tom;
          home-manager.backupFileExtension = "backup-before-home-manager";  
        }
      ];
    };
  };
}