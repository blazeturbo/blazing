# Proper clipboard manager: cliphist keeps a persistent history of
# everything you copy (text + images), fed by wl-paste --watch.
# UI is Noctalia's clipboard panel (Mod+Shift+V); `cliphist list`
# shows history in the terminal, Enter on an entry copies it back.
{ pkgs, ... }: {
  home.packages = [ pkgs.cliphist ];

  systemd.user.services.cliphist = {
    Unit = {
      Description = "Clipboard history manager (cliphist)";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store";
      Restart = "on-failure";
      RestartSec = 1;
    };
  };
}
