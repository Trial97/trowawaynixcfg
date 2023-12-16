{
  config,
  inputs,
  lib,
  ...
}: let
  inherit (builtins) attrValues;
  inherit (lib.lists) optional;
  inherit (lib.modules) mkAliasOptionModule;

  inherit (inputs) home-manager;

  username = "trial";
in {
  imports = [
    (mkAliasOptionModule ["hm"] ["home-manager" "users" username])
    (mkAliasOptionModule ["primaryUser"] ["users" "users" username])

    home-manager.nixosModules.home-manager
  ];

  config = {
    primaryUser = {
      isNormalUser = true;
      # TODO: roles!
      extraGroups =
        ["wheel" "audio" "video" "input" "dialout"]
        ++ optional config.networking.networkmanager.enable "networkmanager"
        ++ optional config.programs.adb.enable "adbusers"
        ++ optional config.programs.wireshark.enable "wireshark"
        ++ optional config.virtualisation.libvirtd.enable "libvirtd"
        ++ optional config.virtualisation.podman.enable "podman";
    };
    nix.settings.trusted-users = [username];

    home-manager.users.trial = {
      # home.homeDirectory = config.users.users."${username}".home;
      home.username = username;

      programs.home-manager.enable = true;

      home.stateVersion = config.system.stateVersion;

      # home.file.".config/awesome".source = ../awesomerc;
      # home.file."awesome".source = ../awesomerc;
      xdg.enable = true;
      xdg.configFile."awesome".source = ../awesomerc;

      home.sessionVariables = {
        XDG_CONFIG_HOME = "/home/trial/.config";
        XDG_DATA_HOME = "/home/trial/.local/share";
      };
      # home.stateVersion = "23.11";
    };

    environment.sessionVariables = lib.mkDefault {
      XDG_CONFIG_HOME = "/home/trial/.config";
      XDG_DATA_HOME = "/home/trial/.local/share";
    };
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = {
        inherit inputs;
      };
    };
  };
}
