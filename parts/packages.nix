{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    mkUserStyles = import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) nix-colors catppuccin-userstyles discord-userstyle;
    };
  in {
    packages = {
      inherit mkUserStyles;
    };
  };
}
