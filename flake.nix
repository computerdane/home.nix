{
  description = "Home Manager configuration of dane";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    utils.url = "github:numtide/flake-utils";
    oneos = {
      url = "github:computerdane/1os";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-unstable.follows = "nixpkgs-unstable";
      inputs.utils.follows = "utils";
    };
    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    {
      nixpkgs,
      nixpkgs-unstable,
      home-manager,
      utils,
      oneos,
      plasma-manager,
      ...
    }:
    utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        pkgs-1os = oneos.packages.${system};
      in
      {
        packages = {
          homeConfigurations."dane" = home-manager.lib.homeManagerConfiguration {
            inherit pkgs;

            modules = [
              plasma-manager.homeManagerModules.plasma-manager

              ./home.nix

              ./features/full.nix
              ./features/go.nix
              ./features/python.nix
              ./features/typescript.nix

              # ./features/kde.nix
            ];

            extraSpecialArgs = {
              inherit pkgs-unstable pkgs-1os;
            };
          };
        };
      }
    );
}
