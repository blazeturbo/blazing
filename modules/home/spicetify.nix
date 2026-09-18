# Spotify, themed by spicetify with a custom color scheme taken straight
# from the Stylix palette (follows wallpaper changes on rebuild).
{ config, ... }:
let
  c = config.lib.stylix.colors;
in {
  programs.spicetify = {
    enable = true;
    customColorScheme = {
      text = c.base05;
      subtext = c.base04;
      main = c.base00;
      sidebar = c.base00;
      player = c.base00;
      card = c.base01;
      shadow = c.base00;
      selected-row = c.base05;
      button = c.base0D;
      button-active = c.base05;
      button-disabled = c.base03;
      tab-active = c.base0D;
      notification = c.base01;
      notification-error = c.base08;
      misc = c.base01;
    };
  };
}
