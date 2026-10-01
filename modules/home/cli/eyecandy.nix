# Eye-candy launchers. Normally all on the Stylix palette (see below),
# but TEMP HARDCODED to the blazefetch theme blue — revert the three
# TEMP-marked pins on wallpaper change.
# Kitty's colors 0-7 are Stylix base00/08/0B/0A/0D/0E/0C/05, so the Nix
# code below picks the slot nearest the accent at build time — everything
# follows wallpaper changes on rebuild, no exceptions.
{ config, pkgs, lib, ... }:
let
  c = config.lib.stylix.colors;

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
  nearestANSI = builtins.toString (lib.foldl' (
      best: i: if dist2 (builtins.elemAt ansiSlots i) < dist2 (builtins.elemAt ansiSlots best) then i else best
    ) 0 (lib.range 1 7));
  nearestIdx = lib.foldl' (
    best: i: if dist2 (builtins.elemAt ansiSlots i) < dist2 (builtins.elemAt ansiSlots best) then i else best
  ) 0 (lib.range 1 7);
  # TEMP HARDCODE (revert to base0D tracking on wallpaper change):
  # everything below is pinned to the blazefetch theme blue so lavat,
  # cmatrix and tty-clock match it. The nearest-slot machinery is kept
  # intact underneath for the revert.
  hardBlueHex = "436694";
  # cmatrix only takes color names, so map the accent's nearest ANSI slot.
  cmatrixNames = [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ];
  cmatrixColor = builtins.elemAt cmatrixNames nearestIdx;
  # Stock cmatrix hardcodes WHITE stream heads (COLOR_WHITE in cmatrix.c),
  # so no flag combo can ever be single-color. Reword those two sites to
  # the matrix color instead. Glyphs: roll an index into 0-9A-Za-z instead
  # of the katakana range, so the rain is letters and numbers only.
  # Length/space rolls use different expressions and are untouched.
  # Literal replaces, no whitespace risk.
  cmatrixBlue = pkgs.cmatrix.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      substituteInPlace cmatrix.c \
        --replace 'COLOR_PAIR(COLOR_WHITE)' 'COLOR_PAIR(mcolor)' \
        --replace '(int) rand() % randnum + randmin' '"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"[rand() % 62]'
    '';
  });
  # lavat takes hex without '#'. TEMP: pinned blazefetch blue
  # (revert to `lib.toUpper c.base0D` on wallpaper change).
  lavatHex = hardBlueHex;
in {
  home.shellAliases = {
    # Big centered clock. TEMP: -C4 pinned blue (revert to -C${nearestANSI}).
    tty-clock = "tty-clock -s -c -C4";
    # Matrix rain, bold, accent-colored, single color (patched heads).
    # TEMP: -C blue pinned (revert to -C ${cmatrixColor}).
    cmatrix = "${cmatrixBlue}/bin/cmatrix -b -C blue";
    # Lava lamp: flat blazefetch blue, uniform, not a gradient.
    lavat = "lavat -g -c ${lavatHex} -k ${lavatHex} -G";
  };
}
