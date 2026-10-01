# Cava audio visualizer: solid theme blue, no gradient.
# TEMP HARDCODED blazefetch blue (revert to '#${c.base0D}' on wallpaper
# change). Shape: thin bars, full height, smooth physics.
{ config, ... }:
let
  c = config.lib.stylix.colors;
in {
  programs.cava = {
    enable = true;
    settings = {
      general = {
        bars = 0; # auto-fill: fixed counts crash narrow windows
        bar_width = 2;
        bar_spacing = 1;
        max_height = 100; # use the full terminal height
        center_align = 1; # center when there's leftover space
        framerate = 60;
      };
      smoothing = {
        monstercat = 1; # graceful falloff instead of jittery raw FFT
        waves = 0; # off — waves make the hill seasick, we want calm
        noise_reduction = 88; # buttery slow hill instead of spiky noise
      };
      color = {
        foreground = "'#436694'"; # TEMP pinned theme blue, no gradient
      };
    };
  };
}
