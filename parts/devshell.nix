{
  perSystem = {pkgs, ...}: let
    inherit (pkgs) mkShell;
  in {
    devShells.default = mkShell {
      packages = [pkgs.tokei];
    };
  };
}
