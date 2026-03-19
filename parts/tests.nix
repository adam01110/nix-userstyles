{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;
in {
  perSystem = {mkUserStyles, ...}: let
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
    testPackage = mkUserStyles palette testUserStyles;
  in {
    packages.test = testPackage;
    checks.test = testPackage;
  };
}
