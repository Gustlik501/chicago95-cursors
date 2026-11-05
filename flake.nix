{
  description = "All prebuilt Chicago95 Xcursor themes";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in rec {
          chicago95-cursors = pkgs.callPackage ./package.nix { };
          default = chicago95-cursors;
        });
      overlays.default = final: prev: {
        chicago95-cursors = final.callPackage ./package.nix { };
      };
      checks = forAllSystems (system: {
        inherit (self.packages.${system}) chicago95-cursors;
      });
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in { default = pkgs.mkShell {
          packages = [ pkgs.xcur2png pkgs.imagemagick pkgs.python3 ];
        }; });
    };
}
