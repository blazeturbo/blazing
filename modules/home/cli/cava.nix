# Cava audio visualizer, monochrome gray ramp on purpose
# (matches the lavat/clock gray, readable on the dark terminal).
{ ... }: {
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
        gradient_color_1 = "'#2e3237'";
        gradient_color_2 = "'#3f454b'";
        gradient_color_3 = "'#50575e'";
        gradient_color_4 = "'#616872'";
        gradient_color_5 = "'#767d85'";
        gradient_color_6 = "'#939aa3'";
      };
    };
  };
}
