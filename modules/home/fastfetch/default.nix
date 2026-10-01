{ config, lib, ... }:
let
  c = config.lib.stylix.colors;

  # Theme blues, pinned to this wallpaper: dominant vivid swatch
  # (#436694) for headers/borders, light swatch (#9CB1C7) for values —
  # both from `magick wallpapers/noctalia.jpg -colors 16 histogram:`.
  # base0D currently resolves grey (#929aa7), so tracking it would keep
  # everything grey — re-pick both if the wallpaper changes.
  themeBlue = "436694";
  themeBlueLight = "9CB1C7";
  osColor = "#${themeBlue}";
  # Dividers follow the theme blue, values follow the foreground
  # (near-white). No nerd icons, no profile row.
  divColor = "#${themeBlue}";
in {
  imports = [ ./blazefetch.nix ./jp2a.nix ];

  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
      display = {
        color = {
          keys = "#${themeBlue}";
          output = "#${themeBlueLight}";
        };
        separator = " ";
        size = {
          binaryPrefix = "iec";
          ndigits = 1;
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

      # Boxed layout: System / Hardware boxes with theme-blue borders +
      # headers, white values. Title (astrid@nixos) is the first row inside
      # System — fetch's native title row is off (title=0 in fetch config).
      # No packages/disk/swap/Status: keeps the panel narrow enough that
      # the spinning logo stays visible beside it.
      modules = [
        {
          type = "custom";
          key = "┌────────────────────── System ──────────────────────┐";
          keyColor = divColor;
        }
        {
          type = "title";
          format = "{user-name}";
          key = " User";
          keyColor = osColor;
        }
        {
          type = "os";
          format = "{pretty-name} {arch}";
          key = " OS";
          keyColor = osColor;
        }
        {
          type = "kernel";
          format = "{sysname} {release}";
          key = " Kernel";
          keyColor = osColor;
        }
        {
          type = "wm";
          format = "{pretty-name} ({protocol-name})";
          key = " WM";
          keyColor = osColor;
        }
        {
          type = "terminal";
          format = "{pretty-name} {version}";
          key = " Terminal";
          keyColor = osColor;
        }
        {
          type = "terminalfont";
          format = "{name}";
          key = " Font";
          keyColor = osColor;
        }
        {
          type = "shell";
          format = "{pretty-name} {version}";
          key = " Shell";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = "└────────────────────────────────────────────────────┘";
          keyColor = divColor;
        }
        {
          type = "custom";
          key = "┌───────────────────── Hardware ─────────────────────┐";
          keyColor = divColor;
        }
        {
          type = "host";
          format = "{name}";
          key = " Host";
          keyColor = osColor;
        }
        {
          type = "command";
          key = " CPU";
          keyColor = osColor;
          text = "N=$(grep -m1 \"model name\" /proc/cpuinfo | cut -d: -f2 | sed -E 's/ *\\(R\\)//g; s/ *\\(TM\\)//g; s/[0-9]+th Gen //g; s/CPU //g; s/@.*//g; s/^ +| +$//g; s/ +/ /g'); M=$(lscpu | grep \"CPU max MHz\" | cut -d: -f2 | tr ',' '.' | cut -d. -f1 | tr -d ' '); if [ -n \"$M\" ]; then echo \"$N @ $((M / 1000)).$(( (M % 1000) / 10 )) GHz\"; else echo \"$N\"; fi";
        }
        {
          type = "gpu";
          format = "{vendor} {name}";
          key = " GPU";
          keyColor = osColor;
        }
        {
          type = "display";
          format = "{width}x{height} @ {refresh-rate}Hz";
          key = " Resolution";
          keyColor = osColor;
        }
        {
          type = "memory";
          format = "{used} / {total}";
          key = " Memory";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = "└────────────────────────────────────────────────────┘";
          keyColor = divColor;
        }
      ];
    };
  };
}
