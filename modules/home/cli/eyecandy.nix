# Eye-candy launchers, computed from the Stylix palette at build time
# so they follow wallpaper changes on rebuild.
{ config, lib, ... }:
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

  # Kitty's colors 0-7 ARE Stylix base00/base08/base0B/base0A/base0D/base0E/base0C/base05,
  # so the nearest slot always matches the active scheme.
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
in {
  home.shellAliases = {
    # Big centered clock with seconds, in the ANSI slot closest to the accent
    tty-clock = "tty-clock -s -c -C${nearestANSI}";
    # Matrix rain, bold
    cmatrix = "cmatrix -b -C blue";
    # Lava lamp: ONE single flat color — gradient mode with both ends set
    # to the exact accent hex, so it's uniform truecolor, not a gradient.
    lavat = "lavat -g -c ${c.base0D} -k ${c.base0D} -G";
  };
}
