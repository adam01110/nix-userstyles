{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;
in {
  perSystem = {
    # keep-sorted start
    mkUserStyles,
    pkgs,
    # keep-sorted end
    ...
  }: let
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
    testPackage = mkUserStyles palette testUserStyles;
  in {
    # keep-sorted start
    checks.test = testPackage;
    packages.test = testPackage;
    # keep-sorted end

    checks.tangled = import ../tests/tangled.nix {
      inherit
        # keep-sorted start
        inputs
        mkUserStyles
        pkgs
        # keep-sorted end
        ;
    };
  };
}
