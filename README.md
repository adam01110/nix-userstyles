# nix-userstyles

This module exports a nix function to generate userstyles for popular
websites using your own color palette.

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
  # https://github.com/catppuccin/userstyles/tree/main/styles
  userStyles = [
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
  ];
in
{
  # no additional extensions needed, just add the userstyles
  # to your firefox profile userContent
  system = pkgs.stdenv.hostPlatform.system;
  programs.firefox.profiles.yourprofile.userContent = ''
    ${builtins.readFile "${
      nix-userstyles.lib.mkUserStyles system palette userStyles
    }"}
  '';
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

  palette =
    config.lib.stylix.colors
    |> filterAttrs (name: _: hasPrefix "base0" name);
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
  ];
in
{
  # no additional extensions needed, just add the userstyles
  # to your firefox profile userContent
  system = pkgs.stdenv.hostPlatform.system;
  programs.firefox.profiles.yourprofile.userContent = ''
    ${builtins.readFile "${
      nix-userstyles.lib.mkUserStyles system palette userStyles
    }"}
  '';
}
```

## Credits

- [Original project (knoopx/nix-userstyles)](https://github.com/knoopx/nix-userstyles)
- [Catppuccin Organization](https://github.com/catppuccin)
- [SenchoPens/base16.nix](https://github.com/SenchoPens/base16.nix)
- [tinted-theming/schemes](https://github.com/tinted-theming/schemes)
