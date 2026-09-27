# Catppuccin Mocha Rosewater cursors, prebuilt X11 theme straight from
# the upstream zip (vendored beside this file). No building from SVG, no
# Inkscape compile — unpack and install. Theme name, verified from the
# zip's index.theme: "catppuccin-mocha-rosewater-cursors".
{ stdenvNoCC, unzip, lib }:
stdenvNoCC.mkDerivation {
  pname = "astrid-catppuccin-mocha-rosewater-cursors";
  version = "1.0";

  src = ./catppuccin-mocha-rosewater-cursors.zip;
  dontUnpack = true;

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/share/icons
    unzip -q "$src" -d theme
    if [ ! -f theme/catppuccin-mocha-rosewater-cursors/index.theme ]; then
      echo "rosewater cursors: theme dir missing from zip" >&2
      exit 1
    fi
    echo "rosewater cursors: $(ls theme/catppuccin-mocha-rosewater-cursors/cursors | wc -l) cursor files"
    grep -E "^Name=" theme/catppuccin-mocha-rosewater-cursors/index.theme
    cp -r theme/catppuccin-mocha-rosewater-cursors $out/share/icons/
    runHook postInstall
  '';

  meta = {
    description = "Catppuccin Mocha Rosewater XCursor theme (prebuilt)";
    license = lib.licenses.gpl2;
  };
}
