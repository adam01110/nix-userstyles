{
  pkgs,
  lib,
  catppuccin-userstyles,
  discord-userstyle,
  ...
} @ inputs: palette: userStyles: let
  inherit
    (builtins)
    concatStringsSep
    elem
    filter
    ;
  inherit (lib) getExe;
  inherit (lib.attrsets) mapAttrsToList;
  inherit
    (lib.strings)
    escapeShellArg
    ;
  importantize = pkgs.callPackage ./importantize.nix inputs;
  catppuccinStyles = filter (s: s != "discord") userStyles;

  catppuccin = import ./catppuccin.nix;
  discord = import ./discord.nix {
    inherit catppuccin concatStringsSep escapeShellArg palette24;
  };

  palette24 =
    palette
    // {
      base11 = palette.base00;
      base12 = palette.base08;
      base15 = palette.base0C;
      base16 = palette.base0D;
      base17 = palette.base0E;
    };

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
      "latte"
      "frappe"
      "macchiato"
      "mocha"
    ];
  in ''
    @catppuccin: {
      ${concatStringsSep "\n      " (map (flavor: "@${flavor}: ${lessPaletteDecl colorDecls}") flavors)}
    };
  '';

  lessVars = {
    accentColor = "lavender";
    additions = 0;
    applyToDocument = 0;
    bg-blur = "20px";
    bg-opacity = 0.2;
    checkColor = "red";
    colorizeLogo = 0;
    contrastColor = "@accentColor";
    darkenShadows = 1;
    darkFlavor = "mocha";
    graphUseAccentColor = 1;
    hideProfilePictures = 0;
    highlight-redirect = 0;
    highlightColor = "@accentColor";
    highlightColor1 = "lavender";
    highlightColor2 = "green";
    highlightColor3 = "peach";
    highlightColor4 = "blue";
    lighterMessages = 0;
    lastMoveColor = "red";
    lightFlavor = "mocha";
    logo = 1;
    oled = 0;
    sponsorBlock = 1;
    styleBoard = 1;
    styleBoardAndPieces = 1;
    stylePieces = 1;
    styleVideoPlayer = 1;
    urls = "localhost";
    zen = 0;
    hideColorSampleTint = 1;
  };

  catppuccinStylesStr = concatStringsSep " " catppuccinStyles;
  buildDiscordStyle = elem "discord" userStyles;
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "userstyles.css";
    phases = ["buildPhase"];
    nativeBuildInputs = with pkgs; [
      dart-sass
      lessc
    ];

    buildPhase = ''
      export NODE_PATH=${pkgs.nodePackages.less-plugin-clean-css}/lib/node_modules

      cp "${catppuccin-userstyles}/lib/lib.less" lib-base16.less
      chmod u+w lib-base16.less
      printf '%s\n' ${escapeShellArg lessPaletteOverride} >> lib-base16.less

      # build catppuccin userstyles
      for style in ${catppuccinStylesStr}; do
        file="${catppuccin-userstyles}/styles/$style/catppuccin.user.less"
        if [ -f "$file" ]; then
          (cat lib-base16.less; cat "$file" | sed '\|@import "https://userstyles.catppuccin.com/lib/lib.less";|d'; echo ${escapeShellArg (lessVarDecl lessVars)}) | \
            lessc --source-map-no-annotation --clean-css="-b --s0 --skip-rebase --skip-advanced --skip-aggressive-merging --skip-shorthand-compacting" - >> catppuccin.userstyles.css
        fi
      done

      # add discord userstyle
      if [ "${
        if buildDiscordStyle
        then "1"
        else "0"
      }" = "1" ]; then
        ${discord.setupScript}

        {
          echo '@-moz-document domain("discord.com") {'
          sass \
            --load-path="$PWD/node_modules" \
            --style=compressed \
            --no-charset \
            --no-source-map \
            "${discord-userstyle}/src/catppuccin-mocha.theme.scss"
          echo '}'
        } >> extra.userstyles.css
      fi

      # replace catppuccin mocha colors with user-defined palette colors
      cat catppuccin.userstyles.css extra.userstyles.css > userstyles.css 2>/dev/null || cat extra.userstyles.css > userstyles.css
      printf '%s\n' ${escapeShellArg (
        concatStringsSep "\n" (
          map (
            mapping: "s|${catppuccin.palette.${mapping.name}}|${palette24.${mapping.base}}|gI"
          )
          catppuccin.replacements
        )
      )} > palette-replacements.sed
      sed -i -f palette-replacements.sed userstyles.css

      # !important
      ${getExe importantize} < userstyles.css > $out
    '';
  }
