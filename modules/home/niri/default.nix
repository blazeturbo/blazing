{ ... }: {
  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    "niri/animations.kdl".source = ./animations.kdl;
    "niri/autostart.kdl".source = ./autostart.kdl;
    "niri/environment.kdl".source = ./environment.kdl;
    "niri/keybinds.kdl".source = ./keybinds.kdl;
    "niri/rules.kdl".source = ./rules.kdl;
    "niri/settings.kdl".source = ./settings.kdl;
  };
}
