{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;
in {
  perSystem = {mkUserStyles, ...}: let
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
  in {
    packages.test = mkUserStyles palette testUserStyles;
  };
}
