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
   stylixImage = ./wallpapers/dank.jpg;
  # stylixImage = ./wallpapers/beautifulmountainscape.jpg;
  # stylixImage = ./wallpapers/zaney-wallpaper.jpg;
  # stylixImage = ./wallpapers/nix-wallpaper-stripes-logo.png;
  # stylixImage = ./wallpapers/purple_gasstation_abstract_dark_night.jpg;
  # stylixImage = ./wallpapers/midnight-reflections-moonlit-sea.webp;
  # stylixImage = ./wallpapers/lofi-Urban-Nightscape.webp;
  # stylixImage = ./wallpapers/alena-aenami-cold.webp;

  # Default Terminal & App Launcher
  terminal = "kitty";
  launcher = "dank";

  # Login manager: "ly" (TUI, matrix), "sddm" (stock theme),
  # "pixie" (SDDM + pixie-sddm Material theme), or "frosted"
  # (custom minimal SDDM theme: name + password only). Only one runs
  # at a time; the others stay configured in the repo, just disabled.
  loginManager = "frosted";

  # Master performance toggle: true = CPU always max (governor
  # performance + EPP locked to performance by intel_pstate, shallow
  # C-states), GPU max power + tiny VRAM OC, lavd gaming scheduler.
  # false = everything in modules/core/performance.nix stays off and
  # the system falls back to NixOS defaults (quiet/cool idle).
  # No kernel rebuild either way (boot flags + services only).
  performanceMode = true;
}
