# JetBrains Mono Nerd Font from the user's own download
# (~/Downloads/JetBrainsMono.zip, Nerd Fonts release): the 4 core Mono
# cuts live beside this file. Family name, verified by fc-scan:
# "JetBrainsMono Nerd Font Mono".
{ stdenvNoCC }:
stdenvNoCC.mkDerivation {
  pname = "astrid-jetbrains-mono-nerd";
  version = "3.5.1";

  src = ./.;

  installPhase = ''
    runHook preInstall
    install -Dm444 *.ttf -t $out/share/fonts/truetype
    runHook postInstall
  '';

  meta = {
    description = "JetBrains Mono Nerd Font, user-provided build";
    license = stdenvNoCC.lib.licenses.ofl;
  };
}
