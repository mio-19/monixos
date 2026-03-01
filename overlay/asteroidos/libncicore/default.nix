{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  glib,
  libglibutil,
  asteroidosMetaAsteroid,
}:

stdenv.mkDerivation rec {
  pname = "libncicore";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "mer-hybris";
    repo = "libncicore";
    rev = "7c4e1a8a743bbd713e684a824442f663cadb7a83";
    hash = "sha256-T2S/UqYwGztXYKuz0b8biwEnrLKXvWxF1YnOZD5bHZY=";
  };

  patches = [
    "${asteroidosMetaAsteroid}/recipes-nemomobile/libnci/libncicore/0001-Makefile-Allow-for-CC-to-be-overridden.patch"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    libglibutil
  ];

  makeFlags = [
    "KEEP_SYMBOLS=1"
    "LIBDIR=${placeholder "out"}/lib"
  ];

  buildPhase = ''
    runHook preBuild
    make release pkgconfig
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install install-dev DESTDIR=$out
    runHook postInstall
  '';

  meta = with lib; {
    description = "mer-hybris libncicore";
    homepage = "https://github.com/mer-hybris/libncicore";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
