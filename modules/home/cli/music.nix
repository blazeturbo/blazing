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
    sptlrx # live synced lyrics for whatever is playing (follows kew via MPRIS)
    playerctl # `playerctl -l` shows MPRIS names if you ever need the whitelist
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

  # sptlrx: live synced lyrics (lrclib) for whatever is playing.
  # `player: mpris` with an empty whitelist follows the first available
  # MPRIS player — that's kew while it's running. Just run `sptlrx`
  # in a split next to kew. No Spotify account needed in this mode.
  xdg.configFile."sptlrx/config.yaml".text = ''
    player: mpris
    mpris:
      players: []
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
    allowNotifications=1
    hideLogo=0
    hideHelp=0


    [visualizer]

    visualizerEnabled=1
    visualizerHeight=6
    visualizerBrailleMode=0

    # 0=lighten, 1=height brightness, 2=reversed, 3=reversed darken.
    visualizerColorType=0

    # 0=thin bars, 1=double width, 2=auto.
    visualizerBarWidth=2


    [colors]

    # 0 = theme file above drives the colors.
    useConfigColors=0


    [track cover]

    coverEnabled=1
    coverAnsi=0
  '';
}
