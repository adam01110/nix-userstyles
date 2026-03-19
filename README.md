<div align="center">

# nix-userstyles

This module generates CSS from the upstream Catppuccin userstyles and remaps
the Catppuccin Mocha palette to your own Base16-compatible palette.

[![CI](https://github.com/adam01110/fzfish/actions/workflows/ci.yml/badge.svg)](https://github.com/adam01110/fzfish/actions/workflows/ci.yml)

</div>

![nix-userstyles](screenshot.png)

## What it provides

- `lib.mkUserStyles`: build the generated upstream CSS as a derivation
- `lib.withExtraCss`: append your own CSS to an existing stylesheet derivation
- bundled support for Catppuccin's Discord theme in addition to the main
  `catppuccin/userstyles` repository

## How it works

`nix-userstyles` compiles upstream LESS and SCSS sources, then replaces the
Catppuccin color tokens with values from your palette.

The input palette must provide the standard Base16 keys:

`base00` `base01` `base02` `base03` `base04` `base05` `base06` `base07`
`base08` `base09` `base0A` `base0B` `base0C` `base0D` `base0E` `base0F`

Additional Base24-style slots used internally are derived automatically.

## Usage

### Build Firefox `userContent.css`

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
        "discord"
      ];
    };
}
```

### Add your own CSS

`mkUserContent` accepts an `extraCss` string that is appended after the generated
userstyles.

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

### Use a Stylix palette

```nix
{
  config,
  lib,
  pkgs,
  nix-userstyles,
  ...
}:
let
  inherit (lib) filterAttrs hasPrefix;

  palette = filterAttrs (name: _: hasPrefix "base0" name) config.lib.stylix.colors;
  system = pkgs.stdenv.hostPlatform.system;
in
{
  home.file.".mozilla/firefox/default/chrome/userContent.css".source =
    nix-userstyles.lib.mkUserContent system {
      inherit palette;
      userStyles = [
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

## Credits

- [Original project (`knoopx/nix-userstyles`)](https://github.com/knoopx/nix-userstyles)
- [Catppuccin userstyles](https://github.com/catppuccin/userstyles)
- [Catppuccin Discord theme](https://github.com/catppuccin/discord)
- [nix-colors](https://github.com/misterio77/nix-colors)
- [tinted-theming/schemes](https://github.com/tinted-theming/schemes)
