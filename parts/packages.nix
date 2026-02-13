{inputs, ...}: {
  flake.lib.mkUserStyles = system: let
    pkgs = import inputs.nixpkgs {inherit system;};
  in
    import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) nix-colors catppuccin-userstyles discord-userstyle;
    };

  perSystem = {pkgs, ...}: let
    mkUserStyles = import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) nix-colors catppuccin-userstyles discord-userstyle;
    };
  in {
    _module.args = {
      inherit mkUserStyles;
    };
  };
}
