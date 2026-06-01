{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;
in {
  perSystem = {mkUserStyles, ...}: let
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
    testPackage = mkUserStyles palette testUserStyles;
  in {
    # keep-sorted start
    checks.test = testPackage;
    packages.test = testPackage;
    # keep-sorted end
  };
}
