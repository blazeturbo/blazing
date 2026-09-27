{ pkgs, ... }: {
  # Cursor: Catppuccin Mocha Rosewater straight from nixpkgs (was a manual
  # unzip in ~/.local/share/icons). pointerCursor owns the theme, size, GTK
  # config and ~/.icons link — XCURSOR_* env comes from here now, Niri reads
  # the same name in its cursor block below.
  home.pointerCursor = {
    package = pkgs.catppuccin-cursors.mochaRosewater;
    name = "catppuccin-mocha-rosewater-cursors";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  stylix.targets = {
    gnome.enable = false;
    yazi.enable = false; # Avoid collision with custom yazi theme.toml
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
