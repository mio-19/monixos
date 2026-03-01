{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  glib,
  libgbinder,
  libglibutil,
  nfcd,
  libncicore,
  asteroidosMetaAsteroid,
}:

stdenv.mkDerivation rec {
  pname = "libnciplugin";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "mer-hybris";
    repo = "libnciplugin";
    rev = "3b844682112733be1b1d6d2bc745dab40f03b152";
    hash = "sha256-qzKhBArLyn4HDRaW9HiwYRebGwEFxphSosp4TuWazmY=";
  };

  patches = [
    "${asteroidosMetaAsteroid}/recipes-nemomobile/libnci/libnciplugin/0001-Makefile-Allow-for-CC-to-be-overridden.patch"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    libgbinder
    libglibutil
    nfcd
    libncicore
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
    description = "mer-hybris libnciplugin";
    homepage = "https://github.com/mer-hybris/libnciplugin";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
