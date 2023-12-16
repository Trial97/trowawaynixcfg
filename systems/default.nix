{inputs, ...}: let
  inherit (inputs) nixpkgs;

  inherit (nixpkgs.lib) attrValues;

  mkHost = {
    hostName,
    system,
    modules,
    overlays ? [],
  }: {
    ${hostName} = nixpkgs.lib.nixosSystem {
      inherit system;

      modules =
        [
          {
            nixpkgs = {inherit overlays;};

            networking.hostName = hostName;
          }

          ./configuration.nix
          ./awesome.nix
          # ./common
          # ./${hostName}
          ./home.nix
        ]
        # ++ (attrValues scrumpkgs.nixosModules)
        ++ modules;

      specialArgs = {
        inherit inputs;
        # lib' = scrumpkgs.lib;
      };
    };
  };
in {
  flake.nixosConfigurations = mkHost {
    system = "x86_64-linux";
    hostName = "nixos";
    modules = [];
  };
}
