# Spotify, wearing our own theme: darkthemer's "text" (spotify-tui look,
# monospace everything) with a custom color scheme taken straight from
# the Stylix palette. Follows wallpaper changes on rebuild.
{ config, pkgs, inputs, ... }:
let
  c = config.lib.stylix.colors;
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  programs.spicetify = {
    enable = true;
    enabledCustomApps = with spicePkgs.apps; [ marketplace ];
    theme = {
      name = "stylix";
      src = ./spicetify-text;
    };
    customColorScheme = {
      text = c.base05;
      subtext = c.base04;
      main = c.base00;
      accent = c.base0D;
      accent-active = c.base0D;
      accent-inactive = c.base02;
      banner = c.base0D;
      border-active = c.base0D;
      border-inactive = c.base03;
      header = c.base03;
      highlight = c.base01;
      notification = c.base0D;
      notification-error = c.base08;
    };
  };
}
