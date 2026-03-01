{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt5,
}:

stdenv.mkDerivation rec {
  pname = "libconnman-qt5";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "libconnman-qt";
    rev = "33679c12dd6de5b707a2d35376f9ad503a88cab9";
    hash = "sha256-HQef3JAFKudjTLmuusM4Nzox0pgusWEGremfKEP9pwk=";
  };

  nativeBuildInputs = [
    pkg-config
    qt5.qmake
  ];

  buildInputs = [
    qt5.qtbase
  ];

  dontWrapQtApps = true;

  configurePhase = ''
    runHook preConfigure

    sed -i 's@$$\[QT_INSTALL_LIBS\]@/usr/lib@g' libconnman-qt/libconnman-qt.pro

    qmake libconnman-qt/libconnman-qt.pro

    runHook postConfigure
  '';

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    make install INSTALL_ROOT=$out
    for pc in "$out"/usr/lib/pkgconfig/*.pc; do
      sed -i "s|^prefix=.*$|prefix=$out/usr|" "$pc"
      sed -i 's|^includedir=/usr/include/|includedir=''${prefix}/include/|' "$pc"
    done
    runHook postInstall
  '';

  meta = with lib; {
    description = "Qt bindings for ConnMan";
    homepage = "https://github.com/sailfishos/libconnman-qt";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
