# SDDM login manager (+ pixie-sddm Material theme / frosted custom theme).
# Enabled only when variables.nix loginManager is "sddm", "pixie" or
# "frosted"; otherwise this whole module is inert and Ly stays in charge.
# Pixie theme follows the system: wallpaper as background, vendored avatar,
# Stylix accent/card/text, Montserrat UI font (mono stays in terminals).
# Blur + animations are built into the theme's Qt6 engine (always on).
# X11 backend on purpose (sddm-wayland + NVIDIA is flaky).
{ config, pkgs, inputs, lib, ... }:
let
  vars = import ../../variables.nix;
  c = config.lib.stylix.colors;
  usePixie = vars.loginManager == "pixie";
  useFrosted = vars.loginManager == "frosted";
  useSddm = vars.loginManager == "sddm" || usePixie || useFrosted;
  pixieTheme = inputs.pixie-sddm.packages.${pkgs.stdenv.hostPlatform.system}.pixie-sddm.override {
    background = vars.stylixImage;
    avatar = ./pixie-avatar.png;
    autoColor = false;
    accentColor = "#${c.base0D}";
    backgroundColor = "#${c.base00}";
    textColor = "#${c.base05}";
    fontFamily = "Montserrat";
  };
  frostedTheme = pkgs.runCommand "frosted-sddm" { } ''
    mkdir -p $out/share/sddm/themes/frosted
    cp ${./frosted/Main.qml} $out/share/sddm/themes/frosted/Main.qml
    cp ${./frosted/metadata.desktop} $out/share/sddm/themes/frosted/metadata.desktop
    cat > $out/share/sddm/themes/frosted/theme.conf <<'EOF'
    [General]
    background=${vars.stylixImage}
    accentColor=#${c.base0D}
    backgroundColor=#${c.base00}
    textColor=#${c.base05}
    fontFamily=Montserrat
    EOF
  '';
in lib.mkIf useSddm {
  # SDDM's greeter needs an X server behind it (SDDM's own Wayland mode +
  # NVIDIA is still flaky; sessions themselves stay Wayland regardless).
  # Enabling X drags xterm along; exclude it so it never lands in the
  # launcher (that stray XTerm entry came from here).
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];
  # Preselect Niri server-side (the theme's role-scan is the backup).
  services.displayManager.defaultSession = "niri";
  services.displayManager.sddm = {
    enable = true;
    package = pkgs.kdePackages.sddm;
    theme = if usePixie then "pixie" else if useFrosted then "frosted" else null;
    settings.Theme.CursorTheme = "breeze_cursors";
    extraPackages = with pkgs.kdePackages; [
      qtsvg
      qtdeclarative
      qt5compat
    ];
  };

  environment.systemPackages =
    lib.optional usePixie pixieTheme
    ++ lib.optional usePixie pkgs.kdePackages.breeze
    ++ lib.optional useFrosted frostedTheme;
}
