_: {
  stylix.targets = {
    gnome.enable = false;
    yazi.enable = false; # Avoid collision with custom yazi theme.toml
    # Off on purpose: the terminal background stays hardcoded gray
    # (see kitty.nix) instead of following the wallpaper palette.
    kitty.enable = false;
    # Off on purpose: spicetify-nix (programs.spicetify) owns Spotify
    # theming with a custom scheme. Stylix's own target builds stock
    # Spotify 1.2.95 that spicetify-cli can't patch (silent no-op).
    spicetify.enable = false;
    qt = {
      enable = true;
      platform = "qtct";
    };
  };
}
