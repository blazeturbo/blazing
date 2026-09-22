# Mononoki Nerd Font from the user's own download
# (~/Downloads/Mononoki.zip, Nerd Fonts release): the 4 core Mono
# cuts live beside this file. Family name, verified by fc-scan:
# "Mononoki Nerd Font Mono".
{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "astrid-mononoki-nerd";
  version = "3.5.0";

  src = ./.;

  installPhase = ''
    runHook preInstall
    install -Dm444 *.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = {
    description = "Mononoki Nerd Font, user-provided build";
    license = stdenvNoCC.lib.licenses.ofl;
  };
}
