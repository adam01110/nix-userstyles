{
  lib,
  ...
}:

basePath:
let
  inherit (lib)
    removePrefix
    splitString
    hasSuffix
    hasPrefix
    ;
  inherit (lib.filesystem) listFilesRecursive;

  relPath = file: removePrefix "/" (removePrefix (toString basePath) (toString file));
  pathSegments = file: splitString "/" (relPath file);
in
lib.filter (file: hasSuffix ".nix" file && lib.all (seg: !hasPrefix "_" seg) (pathSegments file)) (
  listFilesRecursive basePath
)
