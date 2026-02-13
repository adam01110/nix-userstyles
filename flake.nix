{
  inputs = {
    nixpkgs.url = "nixpkgs/nixpkgs-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";
    systems.url = "github:nix-systems/default";

    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    catppuccin-userstyles = {
      url = "github:catppuccin/userstyles";
      flake = false;
    };

    discord-userstyle = {
      url = "https://catppuccin.github.io/discord/dist/catppuccin-mocha.theme.css";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    flake-parts,
    import-tree,
    systems,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;
      imports = [(import-tree ./parts)];
    };
}
