{inputs, ...}: {
  perSystem = {config, ...}: {
    treefmt = {
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

    checks.formatting = config.treefmt.build.check inputs.self;
  };
}
