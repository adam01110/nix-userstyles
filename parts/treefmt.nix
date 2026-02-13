{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
      programs = {
        alejandra.enable = true;
        nixf-diagnose.enable = true;
        deadnix.enable = true;
        statix.enable = true;

        biome.enable = true;

        yamlfmt.enable = true;
        yamllint.enable = true;

        rumdl-check.enable = true;
        rumdl-format.enable = true;
      };
    };
  in {
    formatter = treefmtEval.config.build.wrapper;
    checks.formatting = treefmtEval.config.build.check inputs.self;
  };
}
