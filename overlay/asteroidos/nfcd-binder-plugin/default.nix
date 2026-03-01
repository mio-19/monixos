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
  libnciplugin,
  asteroidosMetaAsteroid,
}:

stdenv.mkDerivation rec {
  pname = "nfcd-binder-plugin";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "mer-hybris";
    repo = "nfcd-binder-plugin";
    rev = "4e9210573118eee93359bdd2653488de4a36649f";
    hash = "sha256-euBgshG41V0LxqZuVobyYyONn+A+rLT/S/QwcmUpAaQ=";
  };

  patches = [
    "${asteroidosMetaAsteroid}/recipes-nemomobile/nfcd/nfcd-binder-plugin/0001-Makefile-Allow-for-CC-to-be-overridden.patch"
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
    libnciplugin
  ];

  makeFlags = [
    "LIBDIR=${placeholder "out"}/lib"
    "PLUGIN_DIR=${placeholder "out"}/lib/nfcd/plugins"
  ];

  buildPhase = ''
    runHook preBuild
    make release
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install DESTDIR=$out
    runHook postInstall
  '';

  meta = with lib; {
    description = "NFC daemon hwbinder plugin used by AsteroidOS hybris stack";
    homepage = "https://github.com/mer-hybris/nfcd-binder-plugin";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
