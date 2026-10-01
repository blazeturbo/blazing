{ config, lib, ... }:
let
  c = config.lib.stylix.colors;

  # Accent-based: keys follow the Stylix accent (base0D), values follow
  # the foreground (base05). Both update on wallpaper change at rebuild.
  osColor = "#${c.base0D}";
  wmColor = "#${c.base0D}";
  pcColor = "#${c.base0D}";
  shColor = "#${c.base0D}";
in {
  imports = [ ./blazefetch.nix ./jp2a.nix ];

  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "#${c.base0D}";
          output = "#${c.base0D}";
        };
        separator = "  ";
        key = {
          width = 12;
        };
        # Colored % numbers like the reference (no bars, no palette row).
        percent = {
          type = 9;
        };
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

      # darius-style: flat icon-key rows, values aligned via key.width,
      # no trees, no headers, no palette. fetch draws the title row.
      modules = [
        {
          type = "os";
          key = " distro";
          keyColor = osColor;
        }
        {
          type = "kernel";
          key = " kernel";
          keyColor = osColor;
        }
        {
          type = "uptime";
          key = " uptime";
          keyColor = osColor;
        }
        {
          type = "packages";
          key = " packages";
          keyColor = osColor;
        }
        {
          type = "shell";
          key = " shell";
          keyColor = shColor;
        }
        {
          type = "terminal";
          key = " terminal";
          keyColor = shColor;
        }
        {
          type = "wm";
          key = " wm";
          keyColor = wmColor;
        }
        {
          type = "cpu";
          format = "{1} ({3}) @ {7}";
          key = " cpu";
          keyColor = pcColor;
        }
        {
          type = "gpu";
          format = "{1} {2}";
          key = " gpu";
          keyColor = pcColor;
        }
        {
          type = "memory";
          key = " memory";
          keyColor = pcColor;
        }
        {
          type = "disk";
          key = " disk";
          keyColor = pcColor;
        }
      ];
    };
  };
}
