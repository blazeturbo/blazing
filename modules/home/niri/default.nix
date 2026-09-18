{ vars, pkgs, ... }:
let
  # Blurred copy of the wallpaper for Niri's overview backdrop.
  # Built from stylixImage on EVERY rebuild — change the wallpaper,
  # rebuild, and the overview blur follows automatically. Nothing to
  # regenerate by hand.
  overviewBlur = pkgs.runCommand "niri-overview-blur.jpg" {
    buildInputs = [ pkgs.imagemagick ];
  } ''
    magick ${vars.stylixImage} -background black -alpha remove -alpha off -blur 0x14 $out
  '';
in {
  xdg.configFile = {
    "niri/config.kdl".source = ./config.kdl;
    "niri/animations.kdl".source = ./animations.kdl;
    "niri/autostart.kdl".text = ''
      spawn-at-startup "dbus-update-activation-environment" "--systemd" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      spawn-at-startup "systemctl" "--user" "import-environment" "WAYLAND_DISPLAY" "XDG_CURRENT_DESKTOP"
      spawn-at-startup "${pkgs.swaybg}/bin/swaybg" "-i" "${vars.stylixImage}" "-m" "fill"
      spawn-at-startup "${pkgs.awww}/bin/awww-daemon" "--namespace" "-backdrop"
      spawn-at-startup "sh" "-c" "for i in 1 2 3 4 5 6; do ${pkgs.awww}/bin/awww img --namespace=-backdrop ${overviewBlur} && break; sleep 1; done"
      spawn-at-startup "sh" "-c" "sleep 0.5 && systemctl --user restart noctalia || ${pkgs.noctalia}/bin/noctalia"
      spawn-at-startup "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
    '';
    "niri/environment.kdl".source = ./environment.kdl;
    "niri/keybinds.kdl".source = ./keybinds.kdl;
    "niri/rules.kdl".source = ./rules.kdl;
    "niri/settings.kdl".source = ./settings.kdl;
  };
}
