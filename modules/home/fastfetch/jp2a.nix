# jp2a – cslarsen/jp2a, vendored in full under ./jp2a-src and built
# natively so `blaze jp2a` (and plain `jp2a`) works without nix-shell.
# Used to rasterize ~/Downloads/logo.avif -> JPEG -> ASCII for the
# spinning blazefetch logo. Binary stays stock upstream.
{ pkgs, ... }:
let
  jp2a-native = pkgs.callPackage ./jp2a-src/nix/package.nix { };
in
{
  home.packages = [ jp2a-native ];
}
