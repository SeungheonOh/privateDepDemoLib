{
  description = "A very basic flake";

  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";

    nixpak = {
      url = "github:max-privatevoid/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nixpkgs, flake-parts, haskellNix, pre-commit-hooks, ... }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      perSystem = { options, config, self', inputs', lib, system, ... }:
        let
          # Need this to use haskell.nix. This adds overlay and config to the nixpkgs.
          pkgs = import nixpkgs {
            overlays = [ haskellNix.overlay ];
            inherit system;
            inherit (haskellNix) config;
          };

          project = pkgs.haskell-nix.project' {
            src = ./.;
            compiler-nix-name = "ghc963";
          };
          flake = project.flake { };
        in
          { inherit (flake) packages devShells; } // {
            packages.sayHello =
              pkgs.writeShellScript "helloWorld" ''
              echo "hello world"
            '';
          };
    };
}
