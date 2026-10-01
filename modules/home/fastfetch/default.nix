{ config, lib, ... }:
let
  c = config.lib.stylix.colors;

  # Accent-based: keys follow the Stylix accent (base0D), values follow
  # the foreground (base05). Both update on wallpaper change at rebuild.
  osColor = "#${c.base0D}";
  # Values + dividers follow the foreground (near-white), like the
  # reference rice: accent headers, white values.
  fgColor = "#${c.base05}";
  divColor = "#${c.base05}";
  # Plain divider (no nerd icons per request).
  div = "────────────────────────────────────────────";
in {
  imports = [ ./blazefetch.nix ./jp2a.nix ];

  programs.fastfetch = {
    enable = true;

    settings = {
      display = {
        color = {
          keys = "#${c.base0D}";
          output = "#${c.base05}";
        };
        separator = "";
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

      # Block layout (reference rice, de-iconed): divider rows between
      # accent header blocks with default white-ish values. No title/
      # profile row, no nerd icons anywhere. fetch draws its own title.
      modules = [
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
        {
          type = "cpu";
          format = "";
          key = "PROCS ";
          keyColor = osColor;
        }
        {
          type = "gpu";
          format = "";
          key = "GRAPH ";
          keyColor = osColor;
        }
        {
          type = "memory";
          format = "";
          key = "MEMRY ";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
        {
          type = "os";
          format = "{pretty-name}";
          key = "OPSYS ";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
        {
          type = "display";
          format = "{inch}\" {refresh-rate}Hz {width}x{height} {name}";
          key = "DISPY ";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
        {
          type = "shell";
          format = "{process-name} - {pretty-name}";
          key = "SHELL ";
          keyColor = osColor;
        }
        {
          type = "terminal";
          format = "{pretty-name}";
          key = "TRMAL ";
          keyColor = osColor;
        }
        {
          type = "terminalfont";
          format = "{name}";
          key = "TRFNT ";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
        {
          type = "disk";
          format = "";
          key = "DISKS ";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
        {
          type = "localip";
          format = "{ifname} {ipv4}";
          key = "IPADD ";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = div;
          keyColor = divColor;
        }
      ];
    };
  };
}
