{ config, lib, ... }:
let
  c = config.lib.stylix.colors;

  # Your wallpaper's palette is nearly monochrome (base08-base0F all sit
  # within a few percent of gray), so plain palette slots all render the
  # same gray. This amplifies each slot's underlying hue x6 in Nix itself:
  # same hues as Stylix, just vivid enough to tell apart. Still derived,
  # never hardcoded.
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
  toHex2 = n:
    let
      digits = "0123456789abcdef";
      hi = builtins.div n 16;
      lo = n - hi * 16;
    in builtins.substring hi 1 digits + builtins.substring lo 1 digits;
  clamp = n: if n < 0 then 0 else if n > 255 then 255 else n;
  luma = rgb: builtins.div (299 * rgb.r + 587 * rgb.g + 114 * rgb.b) 1000;
  boost = hex:
    let
      p = hexRGB hex;
      l = luma p;
      b = v: clamp (l + (v - l) * 6);
    in "#${toHex2 (b p.r)}${toHex2 (b p.g)}${toHex2 (b p.b)}";

  osColor = boost c.base08;
  wmColor = boost c.base0B;
  pcColor = boost c.base0D;
in {
  imports = [ ./fastfetch2.nix ];

  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = boost c.base0E;
          output = "#939aa3";
        };
        separator = "➜ ";
      };

      logo = {
        # Pinned small NixOS mark (plain string = no store path baked in).
        # areofyl/fetch loads the same family for the spinning logo.
        source = "nixos_small";
        padding = {
          top = 10;
          left = 2;
        };
      };

      modules = [
        "break"
        {
          type = "os";
          key = "OS ";
          keyColor = osColor;
        }
        {
          type = "kernel";
          key = " ├  ";
          keyColor = osColor;
        }
        {
          type = "packages";
          key = " ├ 󰏖 ";
          keyColor = osColor;
        }
        "break"
        {
          type = "wm";
          key = "WM ";
          keyColor = wmColor;
        }
        {
          type = "wmtheme";
          key = " ├ 󰉼 ";
          keyColor = wmColor;
        }
        {
          type = "icons";
          key = " ├ 󰀻 ";
          keyColor = wmColor;
        }
        {
          type = "cursor";
          key = " ├  ";
          keyColor = wmColor;
        }
        {
          type = "terminal";
          key = " ├  ";
          keyColor = wmColor;
        }
        {
          type = "terminalfont";
          key = " └  ";
          keyColor = wmColor;
        }
        "break"
        {
          type = "host";
          format = "{5} {1} Type {2}";
          key = "PC ";
          keyColor = pcColor;
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7}";
          key = " ├  ";
          keyColor = pcColor;
        }
        {
          type = "gpu";
          format = "{1} {2}";
          key = " ├ 󰢮 ";
          keyColor = pcColor;
        }
        {
          type = "memory";
          key = " ├  ";
          keyColor = pcColor;
        }
        {
          type = "disk";
          key = " ├ 󰋊 ";
          keyColor = pcColor;
        }
      ];
    };
  };
}
