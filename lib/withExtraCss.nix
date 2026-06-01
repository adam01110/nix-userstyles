{pkgs, ...}: cssFile: extraCss: let
  inherit
    (pkgs)
    # keep-sorted start
    concatText
    writeText
    # keep-sorted end
    ;
in
  if extraCss == ""
  then cssFile
  else
    concatText "userContent.css" [
      cssFile
      (writeText "extra.css" ''

        ${extraCss}
      '')
    ]
