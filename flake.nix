{
  description = "Launcher for the Shanik desktop environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      crane,
      fenix,
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-darwin" ] (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        craneLib = (crane.mkLib pkgs).overrideToolchain fenix.packages.${system}.stable.toolchain;
      in
      {
        devShells.default = craneLib.devShell rec {
          LD_LIBRARY_PATH = pkgs.lib.strings.makeLibraryPath (
            with pkgs;
            [
              wayland
              libxkbcommon
              pango
            ]
          );

          packages = with pkgs; [
            # dependencies
            pkg-config
            wayland
            libxkbcommon
            pango

            # tools
            cargo-watch
            bashInteractive
          ];
        };
      }
    );
}
