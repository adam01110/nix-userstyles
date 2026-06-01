{
  # keep-sorted start
  catppuccin,
  concatStringsSep,
  documentSelector,
  palette24,
  pkgs,
  styleConfig,
  # keep-sorted end
}: let
  inherit (pkgs) writeText;

  discord = import ../discord.nix {
    inherit
      # keep-sorted start
      catppuccin
      concatStringsSep
      palette24
      pkgs
      # keep-sorted end
      ;
  };

  documentStartFile = writeText "discord-document-start.css" ''
    @-moz-document ${concatStringsSep ",\n  " (documentSelector styleConfig [''domain("discord.com")''])} {
  '';

  documentEndFile = writeText "discord-document-end.css" ''
    }
  '';
in {
  inherit (discord) sassLoadPath;
  inherit
    # keep-sorted start
    documentEndFile
    documentStartFile
    # keep-sorted end
    ;
}
