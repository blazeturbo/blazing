{ config, lib, ... }:
let
  c = config.lib.stylix.colors;

  # Theme blue, pinned to this wallpaper: dominant vivid swatch of
  # wallpapers/noctalia.jpg (`magick wallpapers/noctalia.jpg -colors 16
  # histogram:`). base0D currently resolves grey (#929aa7), so tracking
  # it would keep headers+dividers grey — re-pick if the wallpaper
  # changes. Values stay base05 (auto-tracked near-white).
  themeBlue = "436694";
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
          output = "#${c.base05}";
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

      # Boxed layout (reference rice, de-iconed): System / Hardware /
      # Status boxes with theme-blue borders + headers, white values.
      # No title/profile row, no nerd icons, no battery (desktop).
      # fetch draws its own title row above this.
      modules = [
        {
          type = "custom";
          key = "┌────────────────────── System ──────────────────────┐";
          keyColor = divColor;
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
          type = "packages";
          format = "{appimage} (appimage), {flatpak-all} (flatpak), {nix-system} (nix-system), {nix-user} (nix-user)";
          key = " Packages";
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
          format = "{used} / {total} ({percentage})";
          key = " Memory";
          keyColor = osColor;
        }
        {
          type = "swap";
          format = "{used} / {total} ({percentage})";
          key = " Swap";
          keyColor = osColor;
        }
        {
          type = "disk";
          format = "{size-used} / {size-total} ({size-percentage}) - {filesystem} [{mountpoint}]";
          folders = [ "/" ];
          key = " Disk";
          keyColor = osColor;
        }
        {
          type = "custom";
          key = "└────────────────────────────────────────────────────┘";
          keyColor = divColor;
        }
        {
          type = "custom";
          key = "┌────────────────────── Status ──────────────────────┐";
          keyColor = divColor;
        }
        {
          type = "datetime";
          format = "{day-in-month}.{month-pretty}.{year} {hour-pretty}:{minute-pretty}:{second-pretty}";
          key = " Date";
          keyColor = osColor;
        }
        {
          type = "processes";
          format = "{result} running";
          key = " Processes";
          keyColor = osColor;
        }
        {
          type = "command";
          key = " Installed";
          keyColor = osColor;
          text = "LC_ALL=C date -d \"@$(stat -c %W /)\" \"+%d.%m.%Y %H:%M\" 2>/dev/null || echo N/A";
        }
        {
          type = "command";
          key = " OS Age";
          keyColor = osColor;
          text = "echo \"$(( ($(date +%s) - $(stat -c %W /)) / 86400 )) days since install\"";
        }
        {
          type = "uptime";
          format = "{days}d {hours}h {minutes}m";
          key = " Uptime";
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
