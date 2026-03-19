{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;

  mkPkgs = system: import inputs.nixpkgs {inherit system;};

  mkUserStylesFor = pkgs:
    import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) catppuccin-userstyles discord-userstyle;
    };

  withExtraCssFor = pkgs:
    import ../lib/withExtraCss.nix {
      inherit pkgs;
      inherit (pkgs) lib;
    };

  mkUserContentFor = pkgs: let
    mkUserStyles = mkUserStylesFor pkgs;
    withExtraCss = withExtraCssFor pkgs;
  in
    {
      palette,
      userStyles,
      extraCss ? "",
    }:
      withExtraCss (mkUserStyles palette userStyles) extraCss;
in {
  flake.lib.mkUserStyles = system: mkUserStylesFor (mkPkgs system);

  flake.lib.withExtraCss = system: withExtraCssFor (mkPkgs system);

  flake.lib.mkUserContent = system: mkUserContentFor (mkPkgs system);

  perSystem = {pkgs, ...}: let
    mkUserStyles = mkUserStylesFor pkgs;
    withExtraCss = withExtraCssFor pkgs;
    mkUserContent = mkUserContentFor pkgs;
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
  in {
    _module.args = {
      inherit mkUserStyles;
      inherit withExtraCss;
      inherit mkUserContent;
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
