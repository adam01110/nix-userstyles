{
  # keep-sorted start
  catppuccin-userstyles,
  discord-userstyle,
  lib,
  pkgs,
  # keep-sorted end
  ...
} @ inputs: palette: userStyles: let
  inherit
    (builtins)
    # keep-sorted start
    all
    concatStringsSep
    # keep-sorted end
    ;
  inherit (lib) getExe;
  inherit (lib.strings) optionalString;
  inherit
    (pkgs)
    # keep-sorted start
    callPackage
    stdenvNoCC
    # keep-sorted end
    ;
  inherit (stdenvNoCC) mkDerivation;

  importantize = callPackage ./importantize.nix inputs;
  catppuccin = import ./catppuccin.nix;
  palette24 = import ./mkUserStyles/palette.nix {inherit palette;};
  configs = import ./mkUserStyles/configs.nix {inherit userStyles;};
  catppuccinBuild = import ./mkUserStyles/catppuccin.nix {
    inherit
      # keep-sorted start
      catppuccin
      catppuccin-userstyles
      lib
      palette24
      pkgs
      # keep-sorted end
      ;
  };
  discordBuild = import ./mkUserStyles/discord.nix {
    inherit
      # keep-sorted start
      catppuccin
      concatStringsSep
      palette24
      pkgs
      # keep-sorted end
      ;
    inherit (configs) documentSelector;
    styleConfig = configs.discordStyleConfig;
  };
in
  assert all (style: style.defaultSites || style.sites != []) configs.userStyleConfigs;
    mkDerivation {
      name = "userstyles.css";
      phases = ["buildPhase"];
      nativeBuildInputs = with pkgs; [
        # keep-sorted start
        clean-css-cli
        dart-sass
        lessc
        # keep-sorted end
      ];

      buildPhase = ''
        : > catppuccin.userstyles.css

        ${concatStringsSep "\n" (catppuccinBuild.buildCommands configs.catppuccinStyleConfigs)}

        # add discord userstyle
        if [ "${
          if configs.buildDiscordStyle
          then "1"
          else "0"
        }" = "1" ]; then
          sass \
            --load-path=${discordBuild.sassLoadPath} \
            --style=compressed \
            --no-charset \
            --no-source-map \
            "${discord-userstyle}/src/catppuccin-mocha.theme.scss" \
            > discord.userstyles.css
        fi

        # replace catppuccin mocha colors with user-defined palette colors
        sed -f ${catppuccinBuild.paletteReplacementsFile} \
          catppuccin.userstyles.css \
          ${optionalString configs.buildDiscordStyle "${discordBuild.documentStartFile} discord.userstyles.css ${discordBuild.documentEndFile}"} \
          > userstyles.css

        # !important
        ${getExe importantize} < userstyles.css > $out
      '';
    }
