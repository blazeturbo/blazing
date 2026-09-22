# Music: MPD daemon + rmpc client (the terminal stack Linux users love).
# Theme is generated from the Stylix palette on every rebuild — change the
# wallpaper, rebuild, and rmpc follows automatically, same idea as cava.nix.
# rmpc runs in kitty, so album art just works (kitty graphics protocol).
# Usage: `rmpc` to open, `mpc toggle|next|prev` for quick control,
# drop files in ~/Music then press `u` in rmpc to update the library.
{ config, pkgs, ... }:
let
  c = config.lib.stylix.colors;
  # Default rmpc theme, recolored: blue->accent, yellow->gold,
  # black/white->base00/base05, red/green/magenta->matching base colors.
  accent = "#${c.base0D}";
  gold = "#${c.base0A}";
  bg = "#${c.base00}";
  fg = "#${c.base05}";
  red = "#${c.base08}";
  green = "#${c.base0B}";
  magenta = "#${c.base0E}";
in {
  # Daemon: per-user systemd service, PipeWire output, library in ~/Music.
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    extraConfig = ''
      audio_output {
        type "pulse"
        name "PipeWire"
      }
    '';
  };

  programs.rmpc = {
    enable = true;
    config = ''
      (
          address: "127.0.0.1:6600",
          password: None,
          theme: Some("stylix"),
          cache_dir: None,
          on_song_change: None,
          volume_step: 5,
          max_fps: 30,
          scrolloff: 0,
          wrap_navigation: false,
          enable_mouse: true,
          enable_config_hot_reload: true,
          status_update_interval_ms: 1000,
          select_current_song_on_change: false,
          browser_song_sort: [Disc, Track, Artist, Title],
      )
    '';
  };

  # Stylix-derived theme (full default layout, palette swapped).
  xdg.configFile."rmpc/themes/stylix.ron".text = ''
    #![enable(implicit_some)]
    #![enable(unwrap_newtypes)]
    #![enable(unwrap_variant_newtypes)]
    (
        default_album_art_path: None,
        format_tag_separator: " | ",
        browser_column_widths: [20, 38, 42],
        background_color: None,
        text_color: None,
        header_background_color: None,
        modal_background_color: None,
        modal_backdrop: false,
        preview_label_style: (fg: "${gold}"),
        preview_metadata_group_style: (fg: "${gold}", modifiers: "Bold"),
        highlighted_item_style: (fg: "${accent}", modifiers: "Bold"),
        current_item_style: (fg: "${bg}", bg: "${accent}", modifiers: "Bold"),
        borders_style: (fg: "${accent}"),
        highlight_border_style: (fg: "${accent}"),
        symbols: (
            song: "S",
            dir: "D",
            playlist: "P",
            marker: "M",
            ellipsis: "...",
            song_style: None,
            dir_style: None,
            playlist_style: None,
            marker_style: None,
            song_highlighted_style: None,
            dir_highlighted_style: None,
            playlist_highlighted_style: None,
            marker_highlighted_style: None,
            song_current_style: None,
            dir_current_style: None,
            playlist_current_style: None,
            marker_current_style: None,
        ),
        level_styles: (
            info: (fg: "${accent}", bg: "${bg}"),
            warn: (fg: "${gold}", bg: "${bg}"),
            error: (fg: "${red}", bg: "${bg}"),
            debug: (fg: "${green}", bg: "${bg}"),
            trace: (fg: "${magenta}", bg: "${bg}"),
        ),
        progress_bar: (
            symbols: ["█", "█", "█", " ", "█"],
            track_style: None,
            elapsed_style: (fg: "${accent}"),
            thumb_style: (fg: "${accent}"),
            use_track_when_empty: true,
        ),
        scrollbar: (
            symbols: ["│", "█", "▲", "▼"],
            track_style: (),
            ends_style: (),
            thumb_style: (fg: "${accent}"),
        ),
        tab_bar: (
            active_style: (fg: "${bg}", bg: "${accent}", modifiers: "Bold"),
            inactive_style: (),
        ),
        lyrics: (
            timestamp: false
        ),
        browser_song_format: [
            (
                kind: Group([
                    (kind: Property(Track)),
                    (kind: Text(" ")),
                ])
            ),
            (
                kind: Group([
                    (kind: Property(Artist)),
                    (kind: Text(" - ")),
                    (kind: Property(Title)),
                ]),
                default: (kind: Property(Filename))
            ),
        ],
        song_table_format: [
            (
                prop: (kind: Property(Artist),
                    default: (kind: Text("Unknown"))
                ),
                label_prop: (kind: Text("Artist")),
                width: "20%",
            ),
            (
                prop: (kind: Property(Title),
                    default: (kind: Text("Unknown"))
                ),
                label_prop: (kind: Text("Title")),
                width: "35%",
            ),
            (
                prop: (kind: Property(Album), style: (fg: "${fg}"),
                    default: (kind: Text("Unknown Album"), style: (fg: "${fg}"))
                ),
                label_prop: (kind: Text("Album")),
                width: "30%",
            ),
            (
                prop: (kind: Property(Duration),
                    default: (kind: Text("-"))
                ),
                label_prop: (kind: Text("Duration")),
                width: "15%",
                alignment: Right,
            ),
        ],
        layout: Split(
            direction: Vertical,
            panes: [
                (
                    size: "4",
                    pane: Split(
                        direction: Horizontal,
                        panes: [
                            (
                                size: "35",
                                borders: "LEFT | TOP | BOTTOM",
                                border_symbols: Inherited(parent: Rounded, bottom_left: "├"),
                                pane: Component("header_left")
                            ),
                            (
                                size: "100%",
                                borders: "ALL",
                                border_symbols: Inherited(parent: Rounded, top_left: "┬", top_right: "┬", bottom_left: "┴", bottom_right: "┴"),
                                pane: Component("header_center")
                            ),
                            (
                                size: "35",
                                borders: "RIGHT | TOP | BOTTOM",
                                border_symbols: Inherited(parent: Rounded, bottom_right: "┤"),
                                pane: Component("header_right")
                            ),
                        ]
                    )
                ),
                (
                    pane: Pane(Tabs),
                    borders: "RIGHT | LEFT | BOTTOM",
                    border_symbols: Rounded,
                    size: "2",
                ),
                (
                    pane: Pane(TabContent),
                    size: "100%",
                ),
                (
                    size: "3",
                    pane: Split(
                        direction: Horizontal,
                        panes: [
                            (
                                size: "12",
                                borders: "ALL",
                                border_symbols: Inherited(parent: Rounded, top_right: "┬", bottom_right: "┴"),
                                pane: Component("input_mode")
                            ),
                            (
                                size: "100%",
                                borders: "TOP | BOTTOM | RIGHT",
                                border_symbols: Rounded,
                                border_title: [(kind: Text(" ")), (kind: Property(Status(QueueLength()))), (kind: Text(" songs / ")), (kind: Property(Status(QueueTimeTotal()))), (kind: Text(" total time "))],
                                border_title_alignment: Right,
                                pane: Component("progress_bar"),
                            ),
                        ]
                    ),
                ),
            ],
        ),
        components: {
            "state": Pane(Property(
                content: [
                    (kind: Text("["), style: (fg: "${gold}", modifiers: "Bold")),
                    (kind: Property(Status(StateV2( ))), style: (fg: "${gold}", modifiers: "Bold")),
                    (kind: Text("]"), style: (fg: "${gold}", modifiers: "Bold")),
                ], align: Left,
            )),
            "title": Pane(Property(
                content: [
                    (kind: Property(Song(Title)), style: (modifiers: "Bold"),
                        default: (kind: Text("No Song"), style: (modifiers: "Bold"))),
                ], align: Center, scroll_speed: 1
            )),
            "volume": Split(
                direction: Horizontal,
                panes: [
                    (size: "1", pane: Pane(Property(content: [(kind: Text(""))]))),
                    (size: "100%", pane: Pane(Volume(kind: Slider(symbols: (filled: "─", thumb: "●", track: "─"))))),
                    (size: "3", pane: Pane(Property(content: [(kind: Property(Status(Volume)), style: (fg: "${accent}"))], align: Right))),
                    (size: "2", pane: Pane(Property(content: [(kind: Text("%"), style: (fg: "${accent}"))]))),
                ]
            ),
            "elapsed_and_bitrate": Pane(Property(
                content: [
                    (kind: Property(Status(Elapsed))),
                    (kind: Text(" / ")),
                    (kind: Property(Status(Duration))),
                    (kind: Group([
                        (kind: Text(" (")),
                        (kind: Property(Status(Bitrate))),
                        (kind: Text(" kbps)")),
                    ])),
                ],
                align: Left,
            )),
            "artist_and_album": Pane(Property(
                content: [
                    (kind: Property(Song(Artist)), style: (fg: "${gold}", modifiers: "Bold"),
                        default: (kind: Text("Unknown"), style: (fg: "${gold}", modifiers: "Bold"))),
                    (kind: Text(" - ")),
                    (kind: Property(Song(Album)), default: (kind: Text("Unknown Album"))),
                ], align: Center, scroll_speed: 1
            )),
            "states": Split(
                direction: Horizontal,
                panes: [
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                    (
                        size: "100%",
                        pane: Pane(Property(content: [(kind: Property(Status(InputBuffer())), style: (fg: "${accent}"), align: Left)]))
                    ),
                    (
                        size: "6",
                        pane: Pane(Property(content: [
                            (kind: Text("["), style: (fg: "${accent}", modifiers: "Bold")),
                            (kind: Property(Status(RepeatV2(
                                on_label: "z",
                                off_label: "z",
                                on_style: (fg: "${gold}", modifiers: "Bold"),
                                off_style: (fg: "${accent}", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(RandomV2(
                                on_label: "x",
                                off_label: "x",
                                on_style: (fg: "${gold}", modifiers: "Bold"),
                                off_style: (fg: "${accent}", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(ConsumeV2(
                                on_label: "c",
                                off_label: "c",
                                oneshot_label: "c",
                                on_style: (fg: "${gold}", modifiers: "Bold"),
                                off_style: (fg: "${accent}", modifiers: "Dim"),
                                oneshot_style: (fg: "${red}", modifiers: "Dim"),
                            )))),
                            (kind: Property(Status(SingleV2(
                                on_label: "v",
                                off_label: "v",
                                oneshot_label: "v",
                                on_style: (fg: "${gold}", modifiers: "Bold"),
                                off_style: (fg: "${accent}", modifiers: "Dim"),
                                oneshot_style: (fg: "${red}", modifiers: "Bold"),
                            )))),
                            (kind: Text("]"), style: (fg: "${accent}", modifiers: "Bold")),
                            ],
                            align: Right
                        ))
                    ),
                ]
            ),
            "input_mode": Pane(Property(
                content: [
                    (kind: Transform(Replace(content: (kind: Property(Status(InputMode()))), replacements: [
                        (match: "Normal", replace: (kind: Text(" NORMAL "), style: (fg: "${bg}", bg: "${accent}"))),
                        (match: "Insert", replace: (kind: Text(" INSERT "), style: (fg: "${bg}", bg: "${green}"))),
                    ])))
                ], align: Center
            )),
            "header_left": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("state")),
                    (size: "1", pane: Component("elapsed_and_bitrate")),
                ]
            ),
            "header_center": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("title")),
                    (size: "1", pane: Component("artist_and_album")),
                ]
            ),
            "header_right": Split(
                direction: Vertical,
                panes: [
                    (size: "1", pane: Component("volume")),
                    (size: "1", pane: Component("states")),
                ]
            ),
            "progress_bar": Split(
                direction: Horizontal,
                panes: [
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                    (
                        size: "100%",
                        pane: Pane(ProgressBar)
                    ),
                    (
                        size: "1",
                        pane: Pane(Empty())
                    ),
                ]
            )
        },
    )
  '';

  # cmus behavior: never stop at the end of a track — always play the
  # next one, and loop the playlist when there's no next track.
  # (repeat_current stays false so it advances instead of looping one song.)
  xdg.configFile."cmus/rc".text = ''
    set continue=true
    set repeat=true
    set repeat_current=false
    set shuffle=false
    set follow=true
  '';

  # mpc: tiny CLI to control MPD without opening the TUI.
  # cmus: the minimal one — no daemon, just `cmus`, `:add ~/Music`.
  # It uses terminal color names, and kitty is Stylix-themed, so it
  # matches the palette with zero config.
  home.packages = [
    pkgs.mpc
    pkgs.cmus
    # ytmp3: paste a YouTube URL, get an MP3 in ~/Music.
    (pkgs.writeShellApplication {
      name = "ytmp3";
      runtimeInputs = [ pkgs.yt-dlp pkgs.ffmpeg ];
      text = ''
        if [ "$#" -eq 0 ]; then
          echo "usage: ytmp3 <youtube-url> [more urls...]" >&2
          exit 1
        fi
        exec yt-dlp \
          -x --audio-format mp3 --audio-quality 0 \
          --no-playlist --add-metadata \
          -o "$HOME/Music/%(title)s.%(ext)s" "$@"
      '';
    })
  ];
}
