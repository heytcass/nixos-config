{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.users = {
    enable = mkEnableOption "user configuration";

    mainUser = {
      name = mkOption {
        type = types.str;
        default = "nixos";
        description = "Main user account name";
      };

      realName = mkOption {
        type = types.str;
        default = "NixOS User";
        description = "Main user's full name";
      };

      extraGroups = mkOption {
        type = types.listOf types.str;
        default = [];
        description = "Additional groups for the main user";
      };

      packages = mkOption {
        type = types.listOf types.package;
        default = [];
        description = "Packages installed for the main user";
      };
    };

    locale = {
      region = mkOption {
        type = types.str;
        default = "en_US.UTF-8";
        description = "System locale region";
      };
    };
  };

  config = mkIf config.modules.users.enable {
    users.users.${config.modules.users.mainUser.name} = {
      isNormalUser = true;
      description = config.modules.users.mainUser.realName;
      extraGroups = config.modules.users.mainUser.extraGroups;
      packages = config.modules.users.mainUser.packages;
    };

    # Locale settings
    i18n = {
      defaultLocale = config.modules.users.locale.region;
      extraLocaleSettings = {
        LC_ADDRESS = config.modules.users.locale.region;
        LC_IDENTIFICATION = config.modules.users.locale.region;
        LC_MEASUREMENT = config.modules.users.locale.region;
        LC_MONETARY = config.modules.users.locale.region;
        LC_NAME = config.modules.users.locale.region;
        LC_NUMERIC = config.modules.users.locale.region;
        LC_PAPER = config.modules.users.locale.region;
        LC_TELEPHONE = config.modules.users.locale.region;
        LC_TIME = config.modules.users.locale.region;
      };
    };
  };
}