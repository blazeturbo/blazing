{ vars, pkgs, ... }: {
  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    "niri/animations.kdl".source = ./animations.kdl;
    "niri/autostart.kdl".text = ''
      spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      spawn-at-startup "systemctl" "--user" "import-environment" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${vars.stylixImage}" "-m" "fill"
      spawn-at-startup "sh" "-c" "sleep 0.5 && systemctl --user restart noctalia || ${pkgs.noctalia}/bin/noctalia"
    '';
    "niri/environment.kdl".source = ./environment.kdl;
    "niri/keybinds.kdl".source = ./keybinds.kdl;
    "niri/rules.kdl".source = ./rules.kdl;
    "niri/settings.kdl".source = ./settings.kdl;
  };
}
