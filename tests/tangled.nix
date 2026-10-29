{
  # keep-sorted start
  inputs,
  mkUserStyles,
  pkgs,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    attrValues
    readFile
    toJSON
    # keep-sorted end
    ;
  inherit
    (pkgs)
    # keep-sorted start
    postcss
    runCommand
    # keep-sorted end
    ;
  inherit
    (pkgs.lib)
    # keep-sorted start
    escapeShellArg
    getExe
    # keep-sorted end
    ;
  inherit (pkgs.writers) writeJSBin;
  inherit (inputs.nix-colors.colorSchemes.gruvbox-dark-medium) palette;

  lightPalette = inputs.nix-colors.colorSchemes.gruvbox-light-medium.palette;
  defaultStyle = mkUserStyles palette ["tangled"];
  extendedStyle = mkUserStyles palette [
    {
      name = "tangled";
      sites = [''domain("tangled.example")''];
    }
  ];
  replacedStyle = mkUserStyles lightPalette [
    {
      name = "tangled";
      defaultSites = false;
      sites = [''domain("tangled.example")''];
    }
  ];

  check = writeJSBin "check-tangled" {
    libraries = [postcss];
  } (readFile ./tangled.js);

  originalColors = attrValues (import ../lib/catppuccin.nix).palette;
in
  runCommand "tangled-integration" {} ''
    ${getExe check} ${defaultStyle} ${extendedStyle} ${replacedStyle} \
      ${escapeShellArg (toJSON palette)} \
      ${escapeShellArg (toJSON lightPalette)} \
      ${escapeShellArg (toJSON originalColors)}
    touch "$out"
  ''
