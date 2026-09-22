# Music: kew only — "Music for the Shell".
# Standalone player (own backend, no MPD daemon): cover art, built-in
# spectrum visualizer (the bars from the screenshot), library/search,
# lyrics, MPRIS. Run `kew`, press `u` to index ~/Music, `v` for the
# visualizer, `t` to cycle themes, `i` for album-derived colors.
# Theme is generated from the Stylix palette on every rebuild — change
# the wallpaper, rebuild, and kew follows, same idea as cava.nix was.
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
  accent = "#${c.base0D}";
  gold = "#${c.base0A}";
  subtle = "#${c.base03}";
  faint = "#${c.base04}";
  fg = "#${c.base05}";
  red = "#${c.base08}";
  green = "#${c.base0B}";
in {
  home.packages = with pkgs; [
    kew
    chafa # kew renders covers through chafa
    # ytmp3: paste a YouTube URL, get an MP3 in ~/Music (kew's library).
    (writeShellApplication {
      name = "ytmp3";
      runtimeInputs = [ yt-dlp ffmpeg atomicparsley ];
      text = ''
        if [ "$#" -eq 0 ]; then
          echo "usage: ytmp3 <youtube-url> [more urls...]" >&2
          exit 1
        fi
        # -x: best audio -> mp3. Thumbnail embedded as cover art so kew
        # always has an image; metadata embedded for artist/title.
        exec yt-dlp \
          -x --audio-format mp3 --audio-quality 0 \
          --embed-thumbnail --convert-thumbnails jpg \
          --no-playlist --add-metadata \
          -o "$HOME/Music/%(title)s.%(ext)s" "$@"
      '';
    })
  ];

  # Stylix-derived kew theme (format per the kew-tip creator + upstream
  # THEMES-HOWTO: `name=` header, then `key=#hex` lines).
  xdg.configFile."kew/themes/stylix.theme".text = ''
    # Theme generated from the Stylix palette on every rebuild.
    name=stylix
    author=blazing

    accent=${accent}
    text=${fg}
    textDim=${subtle}
    textMuted=${subtle}
    logo=${accent}
    header=${accent}
    footer=${faint}
    help=${subtle}
    link=${accent}
    nowplaying=${gold}
    playlist.rownum=${subtle}
    playlist.title=${fg}
    playlist.playing=${gold}
    trackview.title=${fg}
    trackview.artist=${gold}
    trackview.album=${fg}
    trackview.year=${subtle}
    trackview.time=${subtle}
    trackview.visualizer=${accent}
    trackview.lyrics=${faint}
    library.artist=${accent}
    library.album=${fg}
    library.track=${fg}
    library.enqueued=${subtle}
    library.playing=${gold}
    search.label=${accent}
    search.query=${fg}
    search.result=${fg}
    search.enqueued=${subtle}
    search.playing=${gold}
    progress.filled=${accent}
    progress.empty=${subtle}
    progress.elapsed=${gold}
    status.info=${accent}
    status.warning=${gold}
    status.error=${red}
    status.success=${green}
  '';

  # kewrc: library at ~/Music, visualizer on, image covers, our theme.
  # NOTE: kew only rewrites this file when you run `kew path <dir>`,
  # so keep the library path here and don't run `kew path` (it can't
  # edit this read-only file — edit the path here and rebuild instead).
  # In-app toggles (v/b/t/i/r/s) persist to kewstaterc, which stays
  # writable, so those keep working normally.
  xdg.configFile."kew/kewrc".text = ''
    # Managed by Nix — edit in modules/home/cli/music.nix, then rebuild.
    # Make sure kew is not running when you rebuild, or it may overwrite
    # in-memory settings on quit.

    [miscellaneous]

    path=${config.home.homeDirectory}/Music
    theme=stylix
    # 0 = no desktop popup on every track change.
    allowNotifications=0
    hideLogo=0
    hideHelp=0


    [visualizer]

    visualizerEnabled=1
    visualizerHeight=6
    visualizerBrailleMode=0

    # Flat single-hue bars in the theme's accent color (party/vibrant
    # modes splash rainbow colors instead). Modes: 0=lighten, 1=flat,
    # 2=reversed lighten, 3=party, 4=vibrant, 5=lum vibrant, 6=binning.
    visualizerColorType=1

    # 0=thin bars, 1=double width, 2=auto.
    visualizerBarWidth=2


    [colors]

    # 0 = theme file above drives the colors.
    useConfigColors=0


    [track cover]

    coverEnabled=1
    coverAnsi=0
  '';

  # Custom layout: replaces kew's default current.layout (all sections
  # must exist or kew quits — the rest is verbatim upstream v4.3.4).
  # version MUST match the shipped current.layout for the installed kew
  # (12 for 4.3.4): on a kew update, re-check upstream and bump it here,
  # or kew refuses to start. `nix eval` can't catch that; watch it.
  # What changed vs default: [track] is rebuilt from parts instead of
  # the monolithic `track` component. The cover gets its own row sized
  # to 38% of the height, so the square image renders smaller than full
  # bleed (side padding for free), and metadata/time/visualizer rows sit
  # immediately below it — no more dead gap, text stays glued to the art.
  xdg.configFile."kew/layouts/current.layout".text = ''
    version=12

    [footer_pane]

    row
    height=fixed:1
    col=0

    pane
    component=error_row
    dirty=footer
    width=auto

    row
    height=fixed:1
    col=0

    pane
    component=footer
    dirty=footer
    width=auto

    [playlist_pane]

    row
    height=fixed:5
    col=0

    pane
    component=logo
    dirty=visualizer
    width=auto
    offsetX=1

    row
    height=fixed:3
    col=0

    pane
    component=playlist_header
    width=auto
    offsetX=2

    row
    height=auto
    col=0

    pane
    component=playlist_rows
    dirty=playlist
    width=auto
    offsetX=3

    [playlist]

    row
    height=auto
    col=0

    pane
    component=side_cover
    dirty=song
    width=indent_wide

    pane
    layout=playlist_pane
    width=auto

    row
    height=fixed:2
    col=indent_normal

    pane
    layout=footer_pane
    width=auto

    [library_pane]

    row
    height=fixed:5
    col=0

    pane
    component=logo
    dirty=visualizer
    width=auto
    offsetX=1

    row
    height=fixed:3
    col=0

    pane
    component=library_header
    width=auto
    offsetX=2

    row
    height=auto
    col=0

    pane
    component=library_rows
    dirty=library
    width=auto

    [library]

    row
    height=auto
    col=0

    pane
    component=side_cover
    dirty=song
    width=indent_wide

    pane
    layout=library_pane
    width=auto

    row
    height=fixed:2
    col=indent_normal

    pane
    layout=footer_pane
    width=auto

    [track]

    row
    height=fixed:1
    col=indent

    pane
    component=track_header
    width=fixed:1

    row
    height=percent:34
    col=indent

    pane
    component=cover_centered
    dirty=song
    width=auto

    row
    height=fixed:3
    col=indent

    pane
    component=empty
    width=auto

    row
    height=fixed:4
    col=indent

    pane
    component=metadata
    dirty=song
    width=auto

    row
    height=fixed:1
    col=indent

    pane
    component=time_simple_and_vol
    dirty=visualizer
    width=auto

    row
    height=fixed:6
    col=indent

    pane
    component=vis_and_progress_bar
    dirty=visualizer
    width=auto

    row
    height=fixed:2
    col=indent_normal

    pane
    layout=footer_pane
    width=auto

    [track_landscape_pane]

    row
    height=auto
    col=0

    pane
    component=track_landscape
    dirty=visualizer
    width=auto

    [track_landscape]

    row
    height=window_minus:2
    col=0

    pane
    component=landscape_cover
    dirty=song
    width=from_height

    pane
    layout=track_landscape_pane
    width=auto
    offsetX=1

    [search_pane]

    row
    height=fixed:5
    col=0

    pane
    component=logo
    dirty=visualizer
    width=auto
    offsetX=1

    row
    height=fixed:2
    col=0

    pane
    component=search_header
    width=auto
    offsetX=3

    row
    height=fixed:2
    col=0

    pane
    component=search_box
    dirty=search
    width=auto
    offsetX=3

    row
    height=auto
    col=0

    pane
    component=search_results
    dirty=search
    width=auto
    offsetX=2

    [search]

    row
    height=auto
    col=0

    pane
    component=side_cover
    dirty=song
    width=indent_wide

    pane
    layout=search_pane
    dirty=search
    width=auto

    row
    height=fixed:2
    col=indent_normal

    pane
    layout=footer_pane
    width=auto

    [help_pane]

    row
    height=fixed:5
    col=0

    pane
    component=logo
    dirty=visualizer
    width=auto
    offsetX=3

    row
    height=fixed:2
    col=0

    pane
    component=version
    width=auto
    offsetX=3

    row
    height=auto
    col=0

    pane
    component=help
    width=auto
    offsetX=2

    [help]

    row
    height=auto
    col=0

    pane
    component=side_cover
    dirty=song
    width=indent_wide

    pane
    layout=help_pane
    dirty=help
    width=auto

    row
    height=fixed:2
    col=indent_normal

    pane
    layout=footer_pane
    width=auto
  '';
}
