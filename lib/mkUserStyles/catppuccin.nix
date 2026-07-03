{
  # keep-sorted start
  catppuccin,
  catppuccin-userstyles,
  lib,
  palette24,
  pkgs,
  tangled-catppuccin,
  # keep-sorted end
}: let
  inherit
    (builtins)
    # keep-sorted start
    concatMap
    concatStringsSep
    head
    length
    pathExists
    readFile
    replaceStrings
    tail
    # keep-sorted end
    ;
  inherit (lib.attrsets) mapAttrsToList;
  inherit
    (lib.strings)
    # keep-sorted start
    sanitizeDerivationName
    splitString
    # keep-sorted end
    ;
  inherit (pkgs) writeText;

  lessVarDecl = vars:
    concatStringsSep " " (
      mapAttrsToList (
        name: value: "@${name}: ${toString value};"
      )
      vars
    );

  lessPaletteDecl = colorDecls: "{ ${concatStringsSep " " colorDecls} };";

  lessPaletteOverride = let
    colorDecls =
      map (
        mapping: "@${mapping.name}: #${palette24.${mapping.base}};"
      )
      catppuccin.replacements;
    flavors = [
      # keep-sorted start
      "frappe"
      "latte"
      "macchiato"
      "mocha"
      # keep-sorted end
    ];
  in ''
    @catppuccin: {
      ${concatStringsSep "\n      " (map (flavor: "@${flavor}: ${lessPaletteDecl colorDecls}") flavors)}
    };
  '';

  lessVars = {
    # keep-sorted start
    accentColor = "lavender";
    additions = 0;
    applyToDocument = 0;
    bg-blur = "20px";
    bg-opacity = 0.2;
    checkColor = "red";
    colorizeLogo = 0;
    contrastColor = "@accentColor";
    darkFlavor = "mocha";
    darkenShadows = 1;
    graphUseAccentColor = 1;
    hideColorSampleTint = 1;
    hideProfilePictures = 0;
    highlight-redirect = 0;
    highlightColor = "@accentColor";
    highlightColor1 = "lavender";
    highlightColor2 = "green";
    highlightColor3 = "peach";
    highlightColor4 = "blue";
    lastMoveColor = "red";
    lightFlavor = "mocha";
    lighterMessages = 0;
    logo = 1;
    oled = 0;
    sponsorBlock = 1;
    styleBoard = 1;
    styleBoardAndPieces = 1;
    stylePieces = 1;
    styleVideoPlayer = 1;
    systemFont = 0;
    urls = "localhost";
    zen = 0;
    # keep-sorted end
  };

  stripLibImport = replaceStrings [''@import "https://userstyles.catppuccin.com/lib/lib.less";''] [""];

  patchDocumentSelectors = style: css:
    if style.sites == []
    then css
    else let
      sites = concatStringsSep ", " style.sites;
      documentParts = splitString "@-moz-document " css;
      patchDocumentPart = part: let
        blockParts = splitString "{" part;
        selector = head blockParts;
        body = concatStringsSep "{" (tail blockParts);
        patchedSelector =
          if style.defaultSites
          then "${selector}, ${sites}"
          else sites;
      in
        if length blockParts == 1
        then part
        else "${patchedSelector} {${body}";
    in
      concatStringsSep "@-moz-document " ([(head documentParts)] ++ map patchDocumentPart (tail documentParts));

  buildCommands = styleConfigs:
    concatMap (style: let
      stylePath =
        if style.name == "tangled"
        then "${tangled-catppuccin}/tangled.user.less"
        else "${catppuccin-userstyles}/styles/${style.name}/catppuccin.user.less";
      styleSource = writeText "${sanitizeDerivationName style.name}.user.less" ''
        @import "${catppuccin-userstyles}/lib/lib.less";

        ${lessPaletteOverride}

        ${patchDocumentSelectors style (stripLibImport (readFile stylePath))}

        ${lessVarDecl lessVars}
      '';
    in
      if pathExists stylePath
      then [
        ''
          lessc --source-map-no-annotation ${styleSource} \
            | cleancss -O1 >> catppuccin.userstyles.css
        ''
      ]
      else [])
    styleConfigs;

  paletteReplacementsFile = writeText "palette-replacements.sed" (
    concatStringsSep "\n" (
      map (
        mapping: "s|${catppuccin.palette.${mapping.name}}|${palette24.${mapping.base}}|gI"
      )
      catppuccin.replacements
    )
  );
in {
  inherit
    # keep-sorted start
    buildCommands
    paletteReplacementsFile
    # keep-sorted end
    ;
}
