# cava-layer: hakuspace's transparent top-strip visualizer
# (scripts vendored beside this file, MIT, see headers).
#
# UX: bare `cava` in an interactive shell toggles the layer bar
# (run once to show, again to hide). The real cava binary is untouched:
# the layer spawns it itself, and it stays reachable by absolute path.
# Bar colors track kitty.conf (Stylix-themed) automatically.
{ config, pkgs, lib, ... }:
let
  py = pkgs.python3.withPackages (ps: [ ps.pygobject3 ]);

  typelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    pkgs.gtk3
    pkgs.gtk-layer-shell
    pkgs.vte
    pkgs.pango
    pkgs.gdk-pixbuf
    pkgs.atk
    pkgs.glib
    pkgs.gobject-introspection
  ];
  libPath = lib.makeLibraryPath [
    pkgs.gtk3
    pkgs.gtk-layer-shell
    pkgs.vte
    pkgs.glib
    pkgs.pango
  ];
  dataPath = lib.makeSearchPath "share" [
    pkgs.gtk3
    pkgs.gsettings-desktop-schemas
  ];

  cava-layer = pkgs.writeShellScriptBin "cava-layer" ''
    export GI_TYPELIB_PATH="${typelibPath}"
    export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
    export XDG_DATA_DIRS="${dataPath}:$XDG_DATA_DIRS"
    export CAVA_LAYER_PATH="${config.home.homeDirectory}/.local/bin/cava_layer.py"
    export PATH="${py}/bin:${pkgs.cava}/bin:$PATH"
    exec "${config.home.homeDirectory}/.local/bin/cava_manager.sh" "$@"
  '';
in {
  home.packages = [ cava-layer ];

  home.file = {
    ".local/bin/cava_layer.py".source = ./cava_layer.py;
    ".local/bin/cava_manager.sh" = {
      source = ./cava_manager.sh;
      executable = true;
    };
  };

  # Layer config: upstream template (fat bars, top-hung, white slot
  # so colors follow the kitty/Stylix palette automatically).
  xdg.configFile."cava/cava-layer".text = ''
    [general]
    bar_width = 6
    bar_spacing = 1

    [output]
    method = ncurses
    orientation = top

    [color]
    foreground = white
  '';

  home.shellAliases = {
    cava = "cava-layer toggle";
  };
}
