{inputs, ...}: let
  testUserStyles = [
    "brave-search"
    "bsky"
    "chatgpt"
    "cinny"
    "claude"
    "devdocs"
    "discord"
    "duckduckgo"
    "github"
    "google"
    "hacker-news"
    "lobste.rs"
    "nixos-*"
    "npm"
    "ollama"
    "perplexity"
    "qwant"
    "reddit"
    "spotify-web"
    "stack-overflow"
    "telegram"
    "whatsapp-web"
    "wikipedia"
    "youtube"
  ];
in {
  perSystem = {pkgs, ...}: let
    inherit (inputs.nix-colors.colorSchemes.dracula) palette;
    mkUserStyles = import ../lib/mkUserStyles.nix {
      inherit pkgs;
      inherit (pkgs) lib;
      inherit (inputs) nix-colors catppuccin-userstyles discord-userstyle;
    };
  in {
    packages.test = mkUserStyles palette testUserStyles;
  };
}
