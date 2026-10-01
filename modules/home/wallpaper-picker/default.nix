# Coverflow wallpaper picker (slim fork of YatishGowda09/wallpaper-picker,
# vendored under ./src): skewed-card carousel with color filter, launched
# by Mod+W. Applies through `noctalia msg wallpaper-set` (patched in
# src/wallpaper/WallpaperPicker.qml) so Noctalia state, the
# backdrop-follower repo sync and Stylix re-theming all keep working.
# Deliberately out of scope: video walls (no mpvpaper), DDG search
# (needs python3/curl+network), matugen recolor (Stylix owns colors).
{ pkgs, lib, ... }:
let
  flowSrc = pkgs.runCommand "wallpaper-flow-qml" { } ''
    mkdir -p $out/share/wallpaper-flow
    cp -a ${./src} $out/share/wallpaper-flow
  '';
  wallpaper-flow = pkgs.writeShellApplication {
    name = "wallpaper-flow";
    runtimeInputs = with pkgs; [
      quickshell
      bash
      coreutils
      findutils
      gawk
      gnugrep
      gnused
      file
      procps
      imagemagick
      noctalia
    ];
    text = ''
      export WALLPAPER_DIR="$HOME/Pictures"
      QMLDIR="${flowSrc}/share/wallpaper-flow"
      # Thumbnail/color-marker cache first (no-op after the first run).
      bash "$QMLDIR/prepare-thumbs.sh" >/dev/null 2>&1 || true
      exec quickshell -p "$QMLDIR"
    '';
  };
in
{
  home.packages = [ wallpaper-flow ];
}
