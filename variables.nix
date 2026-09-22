{
  # User & Host configuration
  username = "astrid";
  hostname = "nixos";
  stateVersion = "26.05";
  timezone = "Europe/Paris";
  locale = "en_US.UTF-8";

  # Stylix Wallpaper (Changing this changes the system-wide color palette!)
  # Pick any wallpaper from ./wallpapers/ or add your own:
 # stylixImage = ./wallpapers/Rainnight.jpg;
  # stylixImage = ./wallpapers/AnimeGirlNightSky.jpg;
  # stylixImage = ./wallpapers/Anime-Purple-eyes.png;
   stylixImage = ./wallpapers/noctalia.jpg;
  # stylixImage = ./wallpapers/beautifulmountainscape.jpg;
  # stylixImage = ./wallpapers/zaney-wallpaper.jpg;
  # stylixImage = ./wallpapers/nix-wallpaper-stripes-logo.png;
  # stylixImage = ./wallpapers/purple_gasstation_abstract_dark_night.jpg;
  # stylixImage = ./wallpapers/midnight-reflections-moonlit-sea.webp;
  # stylixImage = ./wallpapers/lofi-Urban-Nightscape.webp;
  # stylixImage = ./wallpapers/alena-aenami-cold.webp;

  # Default Terminal & App Launcher
  terminal = "kitty";
  launcher = "noctalia";

  # Login manager: "ly" (TUI, matrix), "sddm" (stock theme),
  # or "pixie" (SDDM + pixie-sddm Material theme). Only one runs at
  # a time; the others stay configured in the repo, just disabled.
  loginManager = "ly";
}
