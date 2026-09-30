{
  lib,
  stdenv,
  autoreconfHook,
  pkg-config,
  libjpeg,
  curl,
  ncurses,
}:

stdenv.mkDerivation {
  pname = "jp2a";
  version = "1.0.8";

  src = lib.cleanSource ../.;

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libjpeg
    curl
    ncurses
  ];

  meta = {
    description = "JPEG to ASCII converter";
    homepage = "https://github.com/cslarsen/jp2a";
    license = lib.licenses.gpl2Only;
    mainProgram = "jp2a";
    platforms = lib.platforms.unix;
  };
}
