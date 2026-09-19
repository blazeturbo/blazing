{ vars, pkgs, ... }:
let
  # Blurred copy of the wallpaper for Niri's overview backdrop.
  # Built from stylixImage on EVERY rebuild — change the wallpaper,
  # rebuild, and the overview blur follows automatically. Nothing to
  # regenerate by hand.
  overviewBlur = pkgs.runCommand "niri-overview-blur.jpg" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    magick ${vars.stylixImage} -background black -alpha remove -alpha off -blur 0x14 $out
  '';

  # Backdrop follower: Noctalia owns the wallpaper at runtime (picked in its
  # own picker, stored per-monitor in ~/.local/state/noctalia/settings.toml),
  # so the overview backdrop can't be build-time-pinned. This polls that file
  # and on every change: re-blurs + re-pushes the -backdrop awww layer
  # (instant), AND syncs the pick into the repo (wallpapers/noctalia.jpg +
  # variables.nix line, git-staged) so the next manual rebuild re-themes
  # all of Stylix onto it. Same blur recipe as overviewBlur above;
  # absolute tool paths, no new deps.
  backdropFollower = pkgs.writeShellScript "niri-backdrop-follower" ''
    set -uo pipefail
    STATE="$HOME/.local/state/noctalia/settings.toml"
    OUT="''${XDG_CACHE_HOME:-$HOME/.cache}/niri-overview-blur.jpg"
    REPO="$HOME/.config/nixos"
    WALL="$REPO/wallpapers/noctalia.jpg"
    VARS="$REPO/variables.nix"
    MAGICK="${pkgs.imagemagick}/bin/magick"
    AWWW="${pkgs.awww}/bin/awww"
    SLEEP="${pkgs.coreutils}/bin/sleep"
    MV="${pkgs.coreutils}/bin/mv"
    RM="${pkgs.coreutils}/bin/rm"
    GIT="${pkgs.git}/bin/git"
    GREP="${pkgs.gnugrep}/bin/grep"
    SED="${pkgs.gnused}/bin/sed"
    current=""
    pick_path() {
      [ -f "$STATE" ] || return 0
      # Per-monitor section first, [wallpaper.default] as fallback.
      # (index() string matching on purpose: portable across awks,
      # no regex escapes to mistreat.)
      p=$(awk '
        /^\[/ { in_s = (index($0, "[wallpaper.monitors.") == 1); next }
        in_s && /^path *=/ { gsub(/^path *= *"/, ""); gsub(/".*$/, ""); print; exit }
      ' "$STATE")
      if [ -z "$p" ]; then
        p=$(awk '
          /^\[/ { in_s = ($0 == "[wallpaper.default]"); next }
          in_s && /^path *=/ { gsub(/^path *= *"/, ""); gsub(/".*$/, ""); print; exit }
        ' "$STATE")
      fi
      printf '%s' "$p"
      return 0
    }
    apply() {
      [ -f "$1" ] || return 0
      "$MAGICK" "$1" -background black -alpha remove -alpha off -blur 0x14 "$OUT.tmp" \
        && "$MV" "$OUT.tmp" "$OUT" \
        && "$AWWW" img --namespace=-backdrop "$OUT" >/dev/null 2>&1
      "$RM" -f "$OUT.tmp"
    }
    # All logging goes to stdout -> journalctl --user -u niri-backdrop-follower.
    log() { printf '[backdrop-follower] %s\n' "$*"; }
    sync_repo() {
      # Validate first (guards half-written picks), then normalize to JPEG
      # (palette-generator only reads JPEG/PNG/BMP/GIF/HDR/TIFF/TGA — never
      # WebP, whatever the extension claims), write ATOMICALLY (tmp + rename
      # so a concurrent rebuild can never ingest a partial file), stage, and
      # point variables.nix at it. Best-effort: failure keeps last good.
      [ -f "$1" ] || return 1
      "$MAGICK" identify "$1" >/dev/null 2>&1 || return 1
      [ -d "$REPO/wallpapers" ] || return 1
      "$MAGICK" "$1" -background black -alpha remove -alpha off -strip -quality 92 "JPG:$WALL.tmp" || return 1
      "$MV" "$WALL.tmp" "$WALL" || { "$RM" -f "$WALL.tmp"; return 1; }
      (cd "$REPO" && "$GIT" add wallpapers/noctalia.jpg) || return 1
      # Active line only (^[space]*stylixImage): commented alternatives stay intact.
      if ! "$GREP" -q '^[[:space:]]*stylixImage = ./wallpapers/noctalia.jpg;' "$VARS" 2>/dev/null; then
        "$SED" -i 's|^\([[:space:]]*\)stylixImage = .*|\1stylixImage = ./wallpapers/noctalia.jpg;|' "$VARS" || return 1
        log "variables.nix now points at wallpapers/noctalia.jpg"
      fi
      return 0
    }
    while true; do
      next=$(pick_path)
      if [ -n "$next" ] && [ "$next" != "$current" ]; then
        log "wallpaper changed -> $next"
        if apply "$next"; then
          current="$next"
          if sync_repo "$next"; then
            log "repo synced, rebuild to re-theme Stylix"
          else
            log "repo sync failed, keeping last good state"
          fi
        fi
      fi
      "$SLEEP" 2
    done
  '';
in {
  systemd.user.services.niri-backdrop-follower = {
    Unit = {
      Description = "Keep Niri overview backdrop on Noctalia wallpaper";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${backdropFollower}";
      Restart = "on-failure";
      RestartSec = "2";
    };
  };

  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    "niri/animations.kdl".source = ./animations.kdl;
    "niri/autostart.kdl".text = ''
      spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      spawn-at-startup "systemctl" "--user" "import-environment" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${vars.stylixImage}" "-m" "fill"
      spawn-at-startup "${pkgs.awww}/bin/awww-daemon" "--namespace" "-backdrop"
      spawn-at-startup "sh" "-c" "for i in 1 2 3 4 5 6; do ${pkgs.awww}/bin/awww img --namespace=-backdrop ${overviewBlur} && break; sleep 1; done"
      spawn-at-startup "sh" "-c" "sleep 0.5 && systemctl --user restart noctalia || ${pkgs.noctalia}/bin/noctalia"
      spawn-at-startup "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      // GPU: let it use its full stock power (NOT overclocking — no volts,
      // no clocks beyond spec). PowerMizer "Prefer Maximum Performance"
      // instead of Adaptive; runtime state, so re-applied every login.
      spawn-at-startup "sh" "-c" "nvidia-settings -a '[gpu:0]/GpuPowerMizerMode=1' >/dev/null 2>&1 || true"
    '';
    "niri/environment.kdl".source = ./environment.kdl;
    "niri/keybinds.kdl".source = ./keybinds.kdl;
    "niri/rules.kdl".source = ./rules.kdl;
    "niri/settings.kdl".source = ./settings.kdl;
  };
}
