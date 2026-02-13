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
  perSystem = {mkUserStyles, ...}: let
    inherit (inputs.nix-colors.colorSchemes.dracula) palette;
  in {
    packages.test = mkUserStyles palette testUserStyles;
  };
}
