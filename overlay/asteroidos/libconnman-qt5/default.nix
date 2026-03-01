{
  lib,
  stdenv,
  buildPackages,
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
    buildPackages.qt5.qtbase.dev
  ];

  buildInputs = [
    qt5.qtbase
  ];

  depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.stdenv.cc
  ];

  dontWrapQtApps = true;

  configurePhase = ''
    runHook preConfigure

    sed -i 's@$$\[QT_INSTALL_LIBS\]@/usr/lib@g' libconnman-qt/libconnman-qt.pro

    ${buildPackages.qt5.qtbase.dev}/bin/qmake libconnman-qt/libconnman-qt.pro \
      "QMAKE_CC=${stdenv.cc.targetPrefix}gcc" \
      "QMAKE_CXX=${stdenv.cc.targetPrefix}g++" \
      "QMAKE_LINK=${stdenv.cc.targetPrefix}g++" \
      "QMAKE_AR=${stdenv.cc.targetPrefix}ar cqs" \
      "QMAKE_CFLAGS+=-I${qt5.qtbase.dev}/include" \
      "QMAKE_CXXFLAGS+=-I${qt5.qtbase.dev}/include" \
      "QMAKE_INCDIR_QT=${qt5.qtbase.dev}/include" \
      "QMAKE_LIBDIR_QT=${qt5.qtbase.out}/lib" \
      "QMAKE_LIBS_QT=${qt5.qtbase.out}/lib/libQt5DBus.so ${qt5.qtbase.out}/lib/libQt5Network.so ${qt5.qtbase.out}/lib/libQt5Core.so -lpthread"

    # qmake still injects native Qt runtime paths in cross mode; rewrite to target Qt libs.
    sed -i "s|${buildPackages.qt5.qtbase.out}|${qt5.qtbase.out}|g" Makefile

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
