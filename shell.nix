let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = [
    pkgs.age
    pkgs.opentofu
    pkgs.sops
    pkgs.yq
  ];
}
