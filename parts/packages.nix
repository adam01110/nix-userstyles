{inputs, ...}: let
  testUserStyles = import ../lib/testUserStyles.nix;
in {
  flake.lib.mkUserStyles = system: let
    pkgs = import inputs.nixpkgs {inherit system;};
  in
    import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) catppuccin-userstyles discord-userstyle;
    };

  perSystem = {pkgs, ...}: let
    mkUserStyles = import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) catppuccin-userstyles discord-userstyle;
    };
    inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;
  in {
    _module.args = {
      inherit mkUserStyles;
    };

    packages.default = mkUserStyles palette testUserStyles;
  };
}
