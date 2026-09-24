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
        bars = 0; # auto-fill terminal width
        bar_width = 3; # chunky bars instead of thin sticks
        bar_spacing = 1;
        center_align = 1; # center when there's leftover space
        framerate = 60;
      };
      smoothing = {
        monstercat = 1; # graceful falloff instead of jittery raw FFT
        waves = 1; # gentle organic sway on top
        noise_reduction = 60; # a touch livelier than the default 77
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
