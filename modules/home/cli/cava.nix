# Cava audio visualizer, gradient taken from the Stylix palette
# (rebuilds follow wallpaper changes automatically).
{ config, ... }:
let
  c = config.lib.stylix.colors;
  q = hex: "'#${hex}'";
in {
  programs.cava = {
    enable = true;
    settings = {
      general = {
        bar_spacing = 1;
        bar_width = 2;
        frame_rate = 60;
      };
      color = {
        gradient = 1;
        gradient_color_1 = q c.base08;
        gradient_color_2 = q c.base09;
        gradient_color_3 = q c.base0A;
        gradient_color_4 = q c.base0B;
        gradient_color_5 = q c.base0C;
        gradient_color_6 = q c.base0D;
        gradient_color_7 = q c.base0E;
        gradient_color_8 = q c.base0F;
      };
    };
  };
}
