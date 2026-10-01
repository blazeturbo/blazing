# Wallpaper Picker

A Quickshell-based wallpaper picker for Hyprland with skewed parallax cards, color filtering, video wallpaper support, DuckDuckGo image search, and optional matugen recoloring.

## Features

- **Skewed card carousel** — wallpapers displayed as slanted cards with parallax, smooth scrolling and focus animations
- **Color filtering** — wallpapers auto-categorized by dominant color (Red, Orange, Yellow, Green, Blue, Purple, Pink, Monochrome) using ImageMagick
- **Video wallpaper support** — preview and apply `.mp4`/`.mkv`/`.mov`/`.webm` wallpapers via mpvpaper with inline video playback in the picker
- **DuckDuckGo image search** — search and download FHD+ wallpapers directly from the picker, with pause/resume control
- **Multi-monitor support** — select which monitors to apply wallpapers to
- **Matugen recoloring** (optional) — auto-recolor Hyprland borders, kitty terminal, and rofi based on wallpaper colors using [matugen](https://github.com/InioX/matugen)
- **Resolution-aware scaling** — UI scales proportionally across different screen resolutions
- **Catppuccin Mocha defaults** — ships with Catppuccin Mocha as the default theme, dynamically overridden by matugen when recoloring is enabled
- **Thumbnail caching** — fast startup with pre-generated thumbnails and incremental cache updates
- **Random transitions** — wallpapers applied with random swww transition effects

## Dependencies

- [Quickshell](https://quickshell.outfoxxed.me/) — Qt6/QML Wayland shell
- [swww](https://github.com/LGFae/swww) (or `awww`) — wallpaper daemon
- [Hyprland](https://hyprland.org/) — Wayland compositor
- [ImageMagick](https://imagemagick.org/) — thumbnail generation and color extraction
- [curl](https://curl.se/) — downloading search results
- [Python 3](https://www.python.org/) — DuckDuckGo scraper

### Optional

- [mpvpaper](https://github.com/GhostNaN/mpvpaper) — video wallpaper playback
- [matugen](https://github.com/InioX/matugen) — wallpaper-based color scheme generation
- [ffmpeg](https://ffmpeg.org/) — video thumbnail extraction

## Installation

1. Clone this repo into your Hyprland scripts directory:

```bash
git clone https://github.com/YatishGowda09/wallpaper-picker.git \
    ~/.config/hypr/scripts/wallpaper-picker
```

2. Set your wallpaper directory (defaults to `~/Pictures/Wallpapers`):

```bash
export WALLPAPER_DIR="$HOME/Pictures/Wallpapers"
```

3. Generate thumbnails:

```bash
bash ~/.config/hypr/scripts/wallpaper-picker/prepare-thumbs.sh
```

4. Launch with Quickshell:

```bash
quickshell -p ~/.config/hypr/scripts/wallpaper-picker
```

5. (Optional) To enable matugen recoloring, create the flag file:

```bash
touch ~/.config/hypr/scripts/wallpaper-picker/enable-recolor
```

## Keybindings

| Key | Action |
|-----|--------|
| `Left` / `Right` | Navigate wallpapers |
| `Enter` | Apply selected wallpaper |
| `Tab` / `Shift+Tab` | Cycle color filters |
| `Escape` | Close picker (or exit search mode) |
| Scroll wheel | Navigate wallpapers |

## How it works

Wallpapers in your source directory are thumbnailed on first run. The picker displays them in a horizontal carousel with a skewed parallelogram aesthetic. Each thumbnail's dominant color is extracted and cached, enabling instant color-based filtering.

When a wallpaper is selected, it's applied via swww with a random transition effect. If recoloring is enabled, matugen generates a color scheme from the wallpaper and applies it to kitty, rofi, and Hyprland borders.

The DuckDuckGo search scrapes image results filtered to FHD+ resolution, downloads thumbnails incrementally, and lets you apply or download the full-resolution image on selection.

## Credits

Heavily inspired by and based on [imperative-dots](https://github.com/ilyamiro/imperative-dots) by [ilyamiro](https://github.com/ilyamiro). The caching system, scaling approach, and overall architecture are derived from their Quickshell dotfiles.

## License

MIT
