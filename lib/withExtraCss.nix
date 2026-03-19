{
  pkgs,
  lib,
  ...
}: cssFile: extraCss: let
  inherit (lib.strings) escapeShellArg;
in
  pkgs.runCommand "userContent.css" {} ''
    extraCss=${escapeShellArg extraCss}

    cat ${cssFile} > $out

    if [ -n "$extraCss" ]; then
      printf '\n%s\n' "$extraCss" >> $out
    fi
  ''
