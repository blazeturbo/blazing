# Cava audio visualizer: gradient follows the Stylix palette (gray body
# from the wallpaper, accent on top), readable on the dark terminal.
# Shape: chunky centered bars with smooth physics. Colors untouched.
{ config, ... }:
let
  c = config.lib.stylix.colors;
in {
  programs.cava = {
    enable = true;
    settings = {
      general = {
        bars = 0; # auto-fill: fixed counts crash narrow windows
        bar_width = 5; # wide chunky bars, tiny gaps
        bar_spacing = 1;
        center_align = 1; # center when there's leftover space
        framerate = 60;
      };
      smoothing = {
        monstercat = 1; # graceful falloff instead of jittery raw FFT
        waves = 0; # off — waves make the hill seasick, we want calm
        noise_reduction = 88; # buttery slow hill instead of spiky noise
      };
      color = {
        gradient = 1;
        gradient_color_1 = "'#${c.base02}'";
        gradient_color_2 = "'#${c.base03}'";
        gradient_color_3 = "'#${c.base04}'";
        gradient_color_4 = "'#${c.base05}'";
        gradient_color_5 = "'#${c.base06}'";
        gradient_color_6 = "'#${c.base0D}'";
      };
    };
  };
}
