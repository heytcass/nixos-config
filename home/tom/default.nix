{ config, pkgs, ... }:

{
  home = {
    username = "tom";
    homeDirectory = "/home/tom";

    # Match your NixOS version
    stateVersion = "24.11";
  };

  # Let Home Manager manage itself
  programs.home-manager.enable = true;

  # Allow unfree packages (if needed)
  nixpkgs.config.allowUnfree = true;
}