{ config, lib, ... }:
let
  c = config.lib.stylix.colors;

  # Accent-based: keys follow the Stylix accent (base0D), values follow
  # the foreground (base05). Both update on wallpaper change at rebuild.
  osColor = "#${c.base0D}";
  wmColor = "#${c.base0D}";
  pcColor = "#${c.base0D}";
in {
  imports = [ ./fastfetch2.nix ];

  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "#${c.base0D}";
          output = "#${c.base0D}";
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
