# blazefetch – areofyl/fetch, vendored in full under ./fetch-src and patched
# so the info panel comes from OUR fastfetch config instead of its native
# gatherers (see fetch-src/fetch.c: config_info_command). The spinning 3D
# logo engine is 100% upstream.
{ pkgs, config, lib, ... }:
let
  fetch-patched = pkgs.callPackage ./fetch-src/nix/package.nix { };
  c = config.lib.stylix.colors;

  # fetch only accepts named label/logo colors, so pick the name nearest
  # the Stylix accent (base0D) at build time — logo + title follow wallpaper.
  hexDigit = ch:
    {
      "0" = 0; "1" = 1; "2" = 2; "3" = 3; "4" = 4; "5" = 5;
      "6" = 6; "7" = 7; "8" = 8; "9" = 9; "a" = 10; "b" = 11;
      "c" = 12; "d" = 13; "e" = 14; "f" = 15;
    }.${lib.toLower ch};
  hexByte = s: (hexDigit (builtins.substring 0 1 s)) * 16 + hexDigit (builtins.substring 1 1 s);
  hexRGB = s: {
    r = hexByte (builtins.substring 0 2 s);
    g = hexByte (builtins.substring 2 2 s);
    b = hexByte (builtins.substring 4 2 s);
  };
  ansiSlots = [ c.base00 c.base08 c.base0B c.base0A c.base0D c.base0E c.base0C c.base05 ];
  target = hexRGB c.base0D;
  dist2 = hex:
    let p = hexRGB hex;
    in (p.r - target.r) * (p.r - target.r)
      + (p.g - target.g) * (p.g - target.g)
      + (p.b - target.b) * (p.b - target.b);
  nearestIdx = lib.foldl' (
    best: i: if dist2 (builtins.elemAt ansiSlots i) < dist2 (builtins.elemAt ansiSlots best) then i else best
  ) 0 (lib.range 1 7);
  colorNames = [ "white" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ];
  accentName = builtins.elemAt colorNames nearestIdx;
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
    # Spin: xy rotation at 1.6x speed (default 1.0)
    spin=xy
    speed=1.6
    # Stylix accent (nearest named color to base0D #${c.base0D}).
    # Whole logo in the accent slot: uniform, palette-tracked, never
    # hardcoded. Shape, spin, speed and shading untouched.
    label_color=${accentName}
    logo_outer=${accentName}
    logo_inner=${accentName}
  '';

  # Custom logo from ~/Downloads/logo.avif (740x740): converted with temp
  # nix-shell ffmpeg (avif -> JPEG) then vendored `blaze jp2a`
  # (`jp2a --width=60 -i`, inverted so the emblem pops on dark terminals).
  # No `# distro:` line on purpose — without it fetch uses
  # logo_outer/logo_inner above, so the logo stays uniform Stylix-accent
  # tracked. Mixed weights (spaces . , ; : l o x k O 0) give the 3D relief
  # depth; shading stays ascii, spin untouched. Re-run the pipeline any
  # time: ffmpeg -i ~/Downloads/logo.avif /tmp/logo.jpg &&
  # blaze jp2a --width=60 -i /tmp/logo.jpg
  xdg.configFile."fetch/logo.txt".text = ''
                               ;;
                              l00l
                             d0000d.
                           .x00OO00k.
                          'kOOk..kOOk,
                         ;OOOd.  .dOOO;
           lxxxxxxxxxxxxxkkkkxxxxxxkkkkxxxxxxxxxxxxxl
            :kkkkxddddxkkkkddddddddddkkkkxdddddkkkkc
             ,xxxo.  .oxxd'          .dxxo.   lxxx,
              .dxdo..dxdo.            .oddd'.oddd.
               .lddddddl                cddddddl.
                 cxxxx:                  :xxxxl
                 lxxxxc                  cxxxxo.
               .dkkxxkko.               okkkxkkd.
              .xkkx..xkkx.            .xkkx'.xkkk'
             ;kOOo.  .dOOk,          'kOOd.   oOOk:
            cOOOOkkkkkkOOOOkkkkkkkkkkOOOOkkkkkkOOOOl
           lkkkkkkkkkkkkkOOOOkkkkkkOOOOkkkkkkkkkkkkko
                         ;O00x.  .x00O;
                          .O00O'.k00O'
                           .x000000k.
                             d0000d
                              c00l
                               ,,
  '';

  # Alias so `blazefetch` calls it (infinite spin, no frame cap)
  home.shellAliases = {
    blazefetch = "fetch --infinite";
  };
}
