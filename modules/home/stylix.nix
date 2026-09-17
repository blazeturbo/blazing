_: {
  stylix.targets = {
    gnome.enable = false;
    yazi.enable = false; # Avoid collision with custom yazi theme.toml
    qt = {
      enable = true;
      platform = "qtct";
    };
  };
}
