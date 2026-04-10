{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;

  mkPkgs = system: import inputs.nixpkgs {inherit system;};

  mkUserStylesFor = pkgs:
    import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit
        (inputs)
        # keep-sorted start
        catppuccin-userstyles
        discord-userstyle
        # keep-sorted end
        ;
    };

  withExtraCssFor = pkgs:
    import ../lib/withExtraCss.nix {
      inherit pkgs;
      inherit (pkgs) lib;
    };

  mkUserContentFor = pkgs: let
    # keep-sorted start
    mkUserStyles = mkUserStylesFor pkgs;
    withExtraCss = withExtraCssFor pkgs;
    # keep-sorted end
  in
    {
      # keep-sorted start
      extraCss ? "",
      palette,
      userStyles,
      # keep-sorted end
    }:
      withExtraCss (mkUserStyles palette userStyles) extraCss;
in {
  flake.lib = {
    # keep-sorted start
    mkUserContent = system: mkUserContentFor (mkPkgs system);
    mkUserStyles = system: mkUserStylesFor (mkPkgs system);
    withExtraCss = system: withExtraCssFor (mkPkgs system);
    # keep-sorted end
  };

  perSystem = {pkgs, ...}: let
    # keep-sorted start
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
    mkUserContent = mkUserContentFor pkgs;
    mkUserStyles = mkUserStylesFor pkgs;
    withExtraCss = withExtraCssFor pkgs;
    # keep-sorted end
  in {
    _module.args = {
      inherit mkUserContent;
      inherit mkUserStyles;
      inherit withExtraCss;
    };

    packages.default = mkUserStyles palette testUserStyles;
    packages.user-content = mkUserContent {
      inherit palette;
      userStyles = testUserStyles;
    };
    packages.with-extra-css = withExtraCss (mkUserStyles palette testUserStyles) ''
      @-moz-document domain("example.com") {
        body {
          outline: 1px solid red !important;
        }
      }
    '';
  };
}
