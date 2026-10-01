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
    # Contents, not the dir itself: quickshell -p expects shell.qml at root.
    cp -a ${./src}/. $out/share/wallpaper-flow/
  '';
  # quickshell alone lacks the QtMultimedia QML module the picker's video
  # hover-previews import (harmless without videos, fatal at load without
  # the module present). Wrap it with the module on the import path.
  qsWrapped = pkgs.runCommand "quickshell-wrapped" {
    nativeBuildInputs = [ pkgs.makeWrapper ];
  } ''
    mkdir -p $out/bin
    makeWrapper ${pkgs.quickshell}/bin/quickshell $out/bin/quickshell \
      --prefix QML2_IMPORT_PATH : ${pkgs.qt6.qtmultimedia}/lib/qt-6/qml
  '';
  wallpaper-flow = pkgs.writeShellApplication {
    name = "wallpaper-flow";
    runtimeInputs = with pkgs; [
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
      exec ${qsWrapped}/bin/quickshell -p "$QMLDIR"
    '';
  };
in
{
  home.packages = [ wallpaper-flow ];
}
