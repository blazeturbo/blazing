# Dank Material Shell: the bar, launcher, notifications, clipboard,
# settings, screenshots. Replaces Noctalia (boredom-driven upgrade).
#
# Native nixpkgs module (no extra flake input). DMS themes ITSELF live
# from the wallpaper (user call) — Stylix keeps owning the terminal,
# editors and apps. Two themers, different surfaces, no fight.
# NOTE: upstream removed the old enableX feature flags (monitoring,
# wavelength, calendar, dynamic theming are built-in now, deps included
# by default) — that's why this module is just enable + systemd. The
# rest lives in DMS's own settings GUI at runtime, on purpose.
{ ... }: {
  programs.dms-shell = {
    enable = true;
    systemd.enable = true; # replaces the old noctalia user service
  };
}
