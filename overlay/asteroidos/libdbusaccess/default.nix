{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  bison,
  glib,
  libgbinder,
  libglibutil,
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "libdbusaccess";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "libdbusaccess";
    rev = "a311a847c4b6c5bd154858dec63bd5103d11cf63";
    hash = "sha256-xpMao5pHGwpjxqePhwEKVEqpC5SGCSMyOZI9CT5hIIk=";
  };

  nativeBuildInputs = [
    pkg-config
    bison
  ];

  buildInputs = [
    glib
    libgbinder
    libglibutil
    systemd
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
    description = "SailfishOS D-Bus access control library";
    homepage = "https://github.com/sailfishos/libdbusaccess";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
