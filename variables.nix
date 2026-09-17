{
  # User & Host configuration
  username = "astrid";
  hostname = "nixos";
  stateVersion = "26.05";
  timezone = "Europe/Paris";
  locale = "en_US.UTF-8";

  # Stylix Wallpaper (Changing this changes the system-wide color palette!)
  stylixImage = ./wallpapers/Rainnight.jpg;
  # stylixImage = ./wallpapers/AnimeGirlNightSky.jpg;
  # stylixImage = ./wallpapers/mountainscapedark.jpg;

  # Default Terminal & App Launcher
  terminal = "kitty";
  launcher = "noctalia";
}
