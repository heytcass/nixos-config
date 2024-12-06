# modules/audio/default.nix
{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.audio = {
    enable = mkEnableOption "audio configuration";
  };

  config = mkIf config.modules.audio.enable {
    # Pipewire configuration
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # Uncomment if needed:
      # jack.enable = true;
    };
  };
}