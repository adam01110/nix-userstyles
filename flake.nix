{
  description = "Small flake library for generating Firefox userstyles from the upstream Catppuccin themes, then remapping them to any Base16-compatible palette.";

  inputs = {
    # keep-sorted start block=yes newline_separated=yes
    catppuccin-userstyles = {
      url = "github:catppuccin/userstyles";
      flake = false;
    };

    discord-userstyle = {
      url = "github:catppuccin/discord";
      flake = false;
    };

    flake-parts.url = "github:hercules-ci/flake-parts";

    import-tree.url = "github:vic/import-tree";

    nix-colors = {
      url = "github:misterio77/nix-colors";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    systems.url = "github:nix-systems/default";

    tangled-catppuccin = {
      url = "tarball+https://tangled.org/csw.im/tangled-catppuccin/archive/main?format=tar.gz";
      flake = false;
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # keep-sorted end
  };

  outputs = inputs @ {
    # keep-sorted start
    flake-parts,
    import-tree,
    systems,
    # keep-sorted end
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import systems;
      imports = [(import-tree ./modules)];
    };
}
