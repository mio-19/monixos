{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  glib,
  libdbusaccess,
  libgbinder,
  libglibutil,
  systemd,
  file,
  asteroidosMetaAsteroid,
}:

stdenv.mkDerivation rec {
  pname = "nfcd";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "nfcd";
    rev = "0cdf85c5373ea94877af64e20a2b05a80074386a";
    hash = "sha256-MleRVo7Xpa7/WVO5qifsd+hzAeVvGVGhbyj0Mehn3xk=";
  };

  patches = [
    "${asteroidosMetaAsteroid}/recipes-nemomobile/nfcd/nfcd/0001-Makefile-Allow-for-CC-to-be-overridden.patch"
    "${asteroidosMetaAsteroid}/recipes-nemomobile/nfcd/nfcd/0002-Makefile-Allow-for-INSTALL_SYSTEMD_DIR-to-be-overrid.patch"
    "${asteroidosMetaAsteroid}/recipes-nemomobile/nfcd/nfcd/0003-systemd-Allow-the-service-to-be-started-as-root.patch"
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    glib
    libdbusaccess
    libgbinder
    libglibutil
    systemd
    file
  ];

  makeFlags = [
    "KEEP_SYMBOLS=1"
    "INSTALL_SYSTEMD_DIR=${placeholder "out"}/lib/systemd/system"
    "LIBDIR=${placeholder "out"}/lib"
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
    description = "SailfishOS NFC daemon";
    homepage = "https://github.com/sailfishos/nfcd";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
