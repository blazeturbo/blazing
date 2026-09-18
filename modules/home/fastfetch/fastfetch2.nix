# fastfetch2 – areofyl/fetch, vendored in full under ./fetch-src and patched
# so the info panel comes from OUR fastfetch config instead of its native
# gatherers (see fetch-src/fetch.c: config_info_command). The spinning 3D
# logo engine is 100% upstream.
{ pkgs, ... }:
let
  fetch-patched = pkgs.callPackage ./fetch-src/nix/package.nix { };
in
{
  home.packages = [ fetch-patched ];

  # fetch reads ~/.config/fetch/config. Title row stays native,
  # everything below it is `fastfetch --logo none` (our custom modules).
  xdg.configFile."fetch/config".text = ''
    # Info panel source: our fastfetch setup (its own logo disabled,
    # fetch draws the spinning 3D logo itself).
    # --pipe false forces colors on: areofyl captures this through a pipe,
    # and fastfetch strips colors when piped unless told otherwise.
    info_command=fastfetch --logo none --pipe false
    # Render height (rows)
    height=27
  '';

  # Alias so `fastfetch2` calls it (infinite spin, no frame cap)
  home.shellAliases = {
    fastfetch2 = "fetch --infinite";
  };
}
