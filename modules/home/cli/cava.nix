# Cava audio visualizer, follows the Stylix palette: gray body
# (base02-base06 from the wallpaper) with the accent (base0D) on top.
{ config, ... }:
let
  c = config.lib.stylix.colors;
in {
  programs.cava = {
    enable = true;
    settings = {
      general = {
        # Blocky look: explicit low bar count + wide bars, centered.
        # (auto count fills the console with thin smooth bars instead.)
        bars = 28;
        bar_width = 3;
        bar_spacing = 1;
        center_align = 1;
        frame_rate = 60;
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
