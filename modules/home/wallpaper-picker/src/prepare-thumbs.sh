#!/usr/bin/env bash
# Generates/updates the thumbnail cache the picker reads from, mirroring
# imperative-dots' qs_manager.sh::handle_wallpaper_prep(), trimmed to just
# the thumbnail pipeline (no network/bluetooth prep, no IPC routing).
set -uo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/caching.sh"
qs_ensure_cache "wallpaper_picker"

SRC_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
THUMB_DIR="$QS_CACHE_WALLPAPER_PICKER/thumbs"
PREP_LOCK="$QS_RUN_WALLPAPER_PICKER/wallpaper_prep.lock"
MANIFEST="$THUMB_DIR/.manifest"

export MAGICK_THREAD_LIMIT=1
mkdir -p "$THUMB_DIR"

if [ -f "$PREP_LOCK" ] && kill -0 "$(cat "$PREP_LOCK")" 2>/dev/null; then
    exit 0
fi
echo $$ > "$PREP_LOCK"
trap 'rm -f "$PREP_LOCK"' EXIT

THUMB_SOURCE_FILE="$THUMB_DIR/.source_dir"
if [ -f "$THUMB_SOURCE_FILE" ]; then
    read -r CACHED_SRC < "$THUMB_SOURCE_FILE"
    if [ "$CACHED_SRC" != "$SRC_DIR" ]; then
        find "$THUMB_DIR" -maxdepth 1 -type f ! -name '.source_dir' ! -name '.manifest' -delete
        echo "$SRC_DIR" > "$THUMB_SOURCE_FILE"
        : > "$MANIFEST"
    fi
else
    echo "$SRC_DIR" > "$THUMB_SOURCE_FILE"
    : > "$MANIFEST"
fi
[ -f "$MANIFEST" ] || find "$THUMB_DIR" -maxdepth 1 -type f ! -name '.source_dir' ! -name '.manifest' -printf "%f\n" | sort > "$MANIFEST"

SRC_LIST=$(mktemp)
find "$SRC_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" \
       -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mkv" -o -iname "*.mov" -o -iname "*.webm" \) \
    -printf "%f\n" | sort > "$SRC_LIST"

# Drop thumbs whose source wallpaper was deleted. Scanned from the actual
# thumb dir contents, not just the manifest — thumbs written by the DDG
# search download path (WallpaperPicker.qml's applyWallpaper) land here
# directly and never get a manifest entry, so a manifest-only diff would
# never catch them going stale.
find "$THUMB_DIR" -maxdepth 1 -type f ! -name '.source_dir' ! -name '.manifest' -printf "%f\n" \
    | sed 's/^000_//' | sort -u \
    | comm -23 - "$SRC_LIST" | while read -r orphan; do
        rm -f "$THUMB_DIR/$orphan" "$THUMB_DIR/000_$orphan"
        sed -i "/^${orphan}$/d;/^000_${orphan}$/d" "$MANIFEST"
    done

while IFS= read -r filename; do
    img="$SRC_DIR/$filename"
    [ -f "$img" ] || continue

    extension="${filename##*.}"

    # Blazing: upstream converted webp -> jpg IN the source dir and deleted
    # the original. We keep webp as-is (magick thumbnails it natively).
    # (Videos below are unsupported here — no mpvpaper/meson in scope.)

    if [[ "${extension,,}" =~ ^(mp4|mkv|mov|webm)$ ]]; then
        thumb="$THUMB_DIR/000_$filename"
        [ -f "$THUMB_DIR/$filename" ] && rm -f "$THUMB_DIR/$filename"
        if [ ! -f "$thumb" ]; then
            ffmpeg -y -ss 00:00:05 -i "$img" -vframes 1 -threads 1 -f image2 -q:v 2 "$thumb" >/dev/null 2>&1
            echo "000_$filename" >> "$MANIFEST"
        fi
    else
        thumb="$THUMB_DIR/$filename"
        if [ ! -f "$thumb" ]; then
            magick "$img" -resize x420 -quality 70 "$thumb"
            echo "$filename" >> "$MANIFEST"
        fi
    fi
done < <(comm -23 "$SRC_LIST" <(sed 's/^000_//' "$MANIFEST" | sort))

rm -f "$SRC_LIST"
