{ config, pkgs, ... }:

{
  networking = {
    hostName = "gti";
    networkmanager.enable = true;
  };
}
