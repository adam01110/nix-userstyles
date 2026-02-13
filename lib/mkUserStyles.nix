{
  pkgs,
  lib,
  nix-colors,
  catppuccin-userstyles,
  discord-userstyle,
  ...
} @ inputs: palette: userStyles: let
  inherit
    (builtins)
    concatStringsSep
    filter
    elem
    ;
  inherit (lib) getExe;
  inherit (lib.attrsets) mapAttrsToList;
  inherit
    (lib.strings)
    escapeShellArg
    removeSuffix
    hasSuffix
    ;

  listNixModulesRecursive = import ./listNixModulesRecursive.nix inputs;
  importantize = pkgs.callPackage ./importantize.nix inputs;

  extraPkgs = map (
    x:
      pkgs.callPackage x {
        inherit palette nix-colors discord-userstyle;
      }
  ) (listNixModulesRecursive ../userstyles);

  extraPkg = pkgs.stdenvNoCC.mkDerivation {
    name = "extra-userstyles";
    phases = ["installPhase"];
    installPhase = ''
      mkdir -p $out
      for pkg in ${concatStringsSep " " extraPkgs}; do
        name=$(basename "$pkg" ".userstyle.css")
        name=''${name#*-}
        mkdir -p "$out/$name"
        cp "$pkg" "$out/$name/userstyle.css"
      done
    '';
  };

  localStyleNames =
    map (f: removeSuffix ".nix" (baseNameOf f))
    (filter (f: hasSuffix ".nix" f)
      (listNixModulesRecursive ../userstyles));

  catppuccinStyles = filter (s: !elem s localStyleNames) userStyles;

  catppuccin = import ./catppuccin.nix;

  palette24 =
    palette
    // {
      base11 = palette.base00;
      base12 = palette.base08;
      base15 = palette.base0C;
      base16 = palette.base0D;
      base17 = palette.base0E;
    };

  cssVars = ''
    :root {
    ${concatStringsSep "\n" (mapAttrsToList (name: value: "--${name}: #${toString value};") palette24)}
    }
  '';

  lessVarDecl = vars:
    concatStringsSep " " (
      mapAttrsToList (
        name: value: "@${name}: ${toString value};"
      )
      vars
    );

  lessVars = {
    accentColor = "lavender";
    additions = 0;
    applyToDocument = 0;
    bg-blur = "20px";
    bg-opacity = 0.2;
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
    lightFlavor = "mocha";
    logo = 1;
    oled = 0;
    sponsorBlock = 1;
    styleBoardAndPieces = 1;
    stylePieces = 1;
    styleVideoPlayer = 1;
    urls = "localhost";
    zen = 0;
    hideColorSampleTint = 1;
  };

  userStylesStr = concatStringsSep " " userStyles;
  catppuccinStylesStr = concatStringsSep " " catppuccinStyles;
in
  pkgs.stdenvNoCC.mkDerivation {
    name = "userstyles.css";
    phases = ["buildPhase"];
    nativeBuildInputs = with pkgs; [
      lessc
      nodePackages_latest.sass
    ];

    buildPhase = ''
      export NODE_PATH=${pkgs.nodePackages.less-plugin-clean-css}/lib/node_modules

      # build catppuccin userstyles
      for style in ${catppuccinStylesStr}; do
        file="${catppuccin-userstyles}/styles/$style/catppuccin.user.less"
        if [ -f "$file" ]; then
          (cat "${catppuccin-userstyles}/lib/lib.less"; cat "$file" | sed '\|@import "https://userstyles.catppuccin.com/lib/lib.less";|d'; echo ${escapeShellArg (lessVarDecl lessVars)}) | \
            lessc --source-map-no-annotation --clean-css="-b --s0 --skip-rebase --skip-advanced --skip-aggressive-merging --skip-shorthand-compacting" - >> catppuccin.userstyles.css
        fi
      done

      # build extra userstyles
      for style in ${userStylesStr}; do
        file="${extraPkg}/$style/userstyle.css"
        if [ -f "$file" ]; then
          (echo "${cssVars}"; cat "$file") | sass --quiet - >> extra.userstyles.css
        fi
      done

      # replace catppuccin mocha colors with user-defined palette colors
      cat catppuccin.userstyles.css extra.userstyles.css > userstyles.css 2>/dev/null || cat extra.userstyles.css > userstyles.css
      substituteInPlace userstyles.css \
        ${concatStringsSep " \\\n        " (
        map (
          mapping: "--replace-warn ${escapeShellArg catppuccin.palette.${mapping.name}} ${escapeShellArg palette24.${mapping.base}}"
        )
        catppuccin.replacements
      )}

      # !important
      ${getExe importantize} < userstyles.css > $out
    '';
  }
