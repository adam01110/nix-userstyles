# nix-userstyles

This module generates CSS from the upstream Catppuccin userstyles and remaps
the Catppuccin Mocha palette to your own Base16-compatible palette.

![nix-userstyles](screenshot.png)

## Usage

```nix
{
  nix-userstyles,
  pkgs,
  ...
}:
let
  # https://github.com/SenchoPens/base16.nix/blob/main/DOCUMENTATION.md#mkschemeattrs
  # https://github.com/tinted-theming/schemes
  nix-colors = builtins.getFlake "github:misterio77/nix-colors";
  palette = nix-colors.outputs.colorSchemes.dracula.palette;
in
{
  # no additional extensions needed, just add the userstyles
  # to your firefox profile userContent
  system = pkgs.stdenv.hostPlatform.system;
  home.file.".mozilla/firefox/default/chrome/userContent.css".source =
    nix-userstyles.lib.mkUserContent system {
      inherit palette;
      userStyles = [
        # https://github.com/catppuccin/userstyles/tree/main/styles
        "brave-search"
        "bsky"
        "duckduckgo"
        "github"
        "google"
        "hacker-news"
        "lobste.rs"
        "npm"
        "reddit"
        "spotify-web"
        "stack-overflow"
        "whatsapp-web"
        "wikipedia"
        "youtube"
        "discord"
      ];
    };
}
```

```nix
{
  nix-userstyles,
  pkgs,
  ...
}:
let
  nix-colors = builtins.getFlake "github:misterio77/nix-colors";
  palette = nix-colors.outputs.colorSchemes.dracula.palette;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.file.".mozilla/firefox/default/chrome/userContent.css".source =
    nix-userstyles.lib.mkUserContent system {
      inherit palette;
      userStyles = [
        "github"
        "reddit"
        "youtube"
      ];
      extraCss = ''
        @-moz-document domain("example.com") {
          body {
            outline: 1px solid red !important;
          }
        }
      '';
    };
}
```

```nix
{
  config,
  lib,
  pkgs,
  nix-userstyles,
  ...
}:
let
  inherit (lib)
    filterAttrs
    hasPrefix
    ;

  palette = filterAttrs (name: _: hasPrefix "base0" name) config.lib.stylix.colors;
in
{
  # no additional extensions needed, just add the userstyles
  # to your firefox profile userContent
  system = pkgs.stdenv.hostPlatform.system;
  home.file.".mozilla/firefox/default/chrome/userContent.css".source =
    nix-userstyles.lib.mkUserContent system {
      inherit palette;
      userStyles = [
        # https://github.com/catppuccin/userstyles/tree/main/styles
        "brave-search"
        "bsky"
        "cinny"
        "duckduckgo"
        "github"
        "google"
        "hacker-news"
        "lobste.rs"
        "npm"
        "reddit"
        "spotify-web"
        "stack-overflow"
        "whatsapp-web"
        "wikipedia"
        "youtube"
        "discord"
      ];
      extraCss = ''
        @-moz-document domain("example.com") {
          body {
            outline: 1px solid red !important;
          }
        }
      '';
    };
}
```

`mkUserStyles` still returns only the generated upstream CSS derivation.
`withExtraCss` exists if you want to append your own CSS.

## Credits

- [Original project (knoopx/nix-userstyles)](https://github.com/knoopx/nix-userstyles)
- [Catppuccin Organization](https://github.com/catppuccin)
- [SenchoPens/base16.nix](https://github.com/SenchoPens/base16.nix)
- [tinted-theming/schemes](https://github.com/tinted-theming/schemes)
