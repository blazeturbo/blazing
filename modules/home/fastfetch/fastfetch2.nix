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
    # fetch draws the spinning 3D logo itself)
    info_command=fastfetch --logo none
    # Render height (rows)
    height=27
  '';

  # Alias so `fastfetch2` calls it: infinite spin, small logo, NO logo
  # colors (renders in terminal foreground = monochrome, matching the
  # gray info text; the logo's own blue/cyan are ignored).
  home.shellAliases = {
    fastfetch2 = "fetch --infinite -l nixos_small --no-color";
  };
}
