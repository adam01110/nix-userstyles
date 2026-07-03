<div align="center">
  <img src="./assets/nix-logo.png" alt="Nix logo" width="112" />

  # nix-userstyles

  Turn Catppuccin userstyles into Firefox userContent.css with Base16 palettes.

  [![CI](https://img.shields.io/github/actions/workflow/status/adam01110/nix-userstyles/ci.yml?branch=main&style=flat-square&label=CI&labelColor=504945&color=cc241d)](https://github.com/adam01110/nix-userstyles/actions/workflows/ci.yml)
  [![Repo Size](https://img.shields.io/github/repo-size/adam01110/nix-userstyles?style=flat-square&label=repo%20size&labelColor=504945&color=3c3836)](https://github.com/adam01110/nix-userstyles)
  <br />
  [![Nix](https://img.shields.io/badge/Nix-flakes-689d6a?style=flat-square&labelColor=504945&logo=nixos&logoColor=ebdbb2)](https://nixos.wiki/wiki/Flakes)
  [![Catppuccin](https://img.shields.io/badge/Catppuccin-userstyles-b16286?style=flat-square&labelColor=504945&color=b16286)](https://github.com/catppuccin/userstyles)
  [![Firefox](https://img.shields.io/badge/Firefox-userContent.css-458588?style=flat-square&labelColor=504945&logo=firefoxbrowser&logoColor=ebdbb2)](https://support.mozilla.org/en-US/kb/contributors-guide-firefox-advanced-customization)

  [Overview](#overview) - [Usage](#usage) - [Library](#library) - [Notes](#notes)
</div>

I made this because the original project was missing features I wanted and had gone quiet. The maintainer also moved toward AI-generated userstyles, which is not really what I wanted from this tool.

This version keeps the idea simple: build upstream [`catppuccin/userstyles`](https://github.com/catppuccin/userstyles), swap the Catppuccin Mocha colors for a Base16 palette, and output a ready-to-use `userContent.css` that fits the rest of my setup.

It also has bundled handling for the Catppuccin Discord theme and the Tangled Catppuccin style, since those are not in the main userstyles repo.

<div align="center">
  <img src="./assets/screenshot.png" alt="nix-userstyles preview" width="560" />
</div>

## Overview

- Builds Catppuccin userstyles through Nix instead of keeping generated CSS in my config repo.
- Remaps the Mocha palette to any Base16-style palette, including palettes from `nix-colors` or Stylix.
- Produces plain CSS or Firefox-ready `userContent.css`.
- Lets me mix upstream site selectors with my own `@-moz-document` selectors.
- Appends extra CSS when I need small local fixes that are not worth upstreaming.
- Forces generated declarations to `!important`, because site CSS usually does not play nice.

## Usage

Add the flake as an input and use one of the exported helpers from `nix-userstyles.lib`.

```nix
{
  inputs = {
    nix-userstyles.url = "github:adam01110/nix-userstyles";
  };
}
```

### Build Firefox `userContent.css`

```nix
{
  nix-userstyles,
  pkgs,
  ...
}:
let
  nix-colors = builtins.getFlake "github:misterio77/nix-colors";
  palette = nix-colors.outputs.colorSchemes.gruvbox-dark-medium.palette;
  system = pkgs.stdenv.hostPlatform.system;
in {
  home.file.".mozilla/firefox/default/chrome/userContent.css".source =
    nix-userstyles.lib.mkUserContent system {
      inherit palette;
      userStyles = [
        "github"
        {
          name = "reddit";
          defaultSites = true;
          sites = [ ''domain("old.reddit.com")'' ];
        }
        "youtube"
      ];
    };
}
```

Each `userStyles` entry can be either a style name string or an attribute set. Attribute set entries accept `name`, `defaultSites`, and `sites`.

`defaultSites` defaults to `true`, so custom `sites` are added to the upstream Catppuccin selectors. Set `defaultSites = false` when you want to replace the upstream selectors completely.

`sites` entries are raw Firefox `@-moz-document` selector fragments, such as `''domain("example.com")''`, `''url-prefix("https://example.com/app")''`, or `''regexp("https://example\\.com/.*")''`.

### Append your own CSS

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
in {
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
  nix-userstyles,
  pkgs,
  ...
}:
let
  inherit (lib) filterAttrs hasPrefix;

  palette = filterAttrs (name: _: hasPrefix "base0" name) config.lib.stylix.colors;
  system = pkgs.stdenv.hostPlatform.system;
in {
  home.file.".mozilla/firefox/default/chrome/userContent.css".source =
    nix-userstyles.lib.mkUserContent system {
      inherit palette;
      userStyles = [
        "github"
        "reddit"
        "youtube"
      ];
    };
}
```

> [!NOTE]
> The palette must provide the standard Base16 keys from `base00` through `base0F`. The extra color slots needed for the Catppuccin mapping are derived automatically.

## Library

| Export | What I use it for |
| --- | --- |
| `lib.mkUserStyles` | Build the generated stylesheet derivation |
| `lib.withExtraCss` | Append local CSS to an existing stylesheet derivation |
| `lib.mkUserContent` | Build a complete Firefox `userContent.css` in one call |

The flake also exposes a few package outputs for quick testing:

| Output | Role |
| --- | --- |
| `packages.default` | Generated stylesheet using the bundled test style list |
| `packages.user-content` | Firefox-ready `userContent.css` |
| `packages.with-extra-css` | Generated stylesheet with appended custom CSS |
| `packages.test` | Same build used by CI checks |

## Notes

- Style names come from the upstream Catppuccin repositories. `lib/testUserStyles.nix` is the easiest place to check the list I test against.
- `discord` is built separately from the upstream Discord SCSS theme.
- `tangled` is built separately from [`csw.im/tangled-catppuccin`](https://tangled.org/csw.im/tangled-catppuccin).
- The generated CSS is post-processed so every declaration becomes `!important`.
- This is mostly built for my own Firefox setup, but the helpers should be reusable if your config is also palette-driven.

## Credits

- [Original project (`knoopx/nix-userstyles`)](https://github.com/knoopx/nix-userstyles)
- [Catppuccin userstyles](https://github.com/catppuccin/userstyles)
- [Catppuccin Discord theme](https://github.com/catppuccin/discord)
- [Tangled Catppuccin](https://tangled.org/csw.im/tangled-catppuccin)
- [nix-colors](https://github.com/misterio77/nix-colors)
