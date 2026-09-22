# SDDM login manager (+ pixie-sddm Material theme option).
# Enabled only when variables.nix loginManager is "sddm" or "pixie";
# otherwise this whole module is inert and Ly stays in charge.
# Pixie theme follows the system: wallpaper as background, Stylix accent,
# Stylix monospace. X11 backend on purpose (sddm-wayland + NVIDIA is flaky).
{ config, pkgs, inputs, lib, ... }:
let
  vars = import ../../variables.nix;
  c = config.lib.stylix.colors;
  usePixie = vars.loginManager == "pixie";
  useSddm = vars.loginManager == "sddm" || usePixie;
  pixieTheme = inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
    background = vars.stylixImage;
    autoColor = false;
    accentColor = "#${c.base0D}";
    fontFamily = "JetBrainsMono Nerd Font Mono";
  };
in lib.mkIf useSddm {
  # SDDM's greeter needs an X server behind it (SDDM's own Wayland mode +
  # NVIDIA is still flaky; sessions themselves stay Wayland regardless).
  services.xserver.enable = true;
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = if usePixie then "pixie" else null;
    settings.Theme.CursorTheme = "breeze_cursors";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtdeclarative
      qt5compat
    ];
  };

  environment.systemPackages = lib.mkIf usePixie [
    pixieTheme
    pkgs.kdePackages.breeze
  ];
}
