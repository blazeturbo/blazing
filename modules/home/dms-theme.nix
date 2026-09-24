# DMS "Stylix" theme: single palette everywhere. Generates the same
# custom-theme JSON upstream's Stylix target would (dark+light, Material
# roles incl. the ones workspaces/bars read), then COPIES it to a real
# file in ~/.config — never a symlink, because DMS cannot read theme
# files out of /nix/store (confirmed upstream issue). DMS live-reloads
# it on change, so later rebuilds re-theme the shell with zero clicks.
# One-time manual step after the first rebuild: DMS Settings → Theme →
# Custom → select ~/.config/DankMaterialShell/themes/stylix.json.
# It persists in DMS's own writable settings from then on.
{ config, pkgs, lib, ... }:
let
  c = config.lib.stylix.colors;
  theme = {
    name = "Stylix";
    primary = "#${c.base0D}";
    primaryText = "#${c.base00}";
    primaryContainer = "#${c.base0C}";
    secondary = "#${c.base0E}";
    surface = "#${c.base01}";
    surfaceText = "#${c.base05}";
    surfaceVariant = "#${c.base02}";
    surfaceVariantText = "#${c.base04}";
    surfaceTint = "#${c.base0D}";
    background = "#${c.base00}";
    backgroundText = "#${c.base05}";
    outline = "#${c.base03}";
    surfaceContainer = "#${c.base01}";
    surfaceContainerHigh = "#${c.base02}";
    surfaceContainerHighest = "#${c.base03}";
    error = "#${c.base08}";
    warning = "#${c.base0A}";
    info = "#${c.base0C}";
  };
  themeFile = pkgs.writeText "dms-stylix-theme.json" (
    builtins.toJSON {
      dark = theme;
      light = theme;
    }
  );
in {
  home.activation.dmsStylixTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "$HOME/.config/DankMaterialShell/themes"
    $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m644 ${themeFile} "$HOME/.config/DankMaterialShell/themes/stylix.json"
  '';
}
