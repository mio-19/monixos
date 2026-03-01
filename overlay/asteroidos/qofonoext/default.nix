{
  lib,
  stdenv,
  buildPackages,
  fetchFromGitHub,
  pkg-config,
  qt5,
  libqofono,
}:

stdenv.mkDerivation rec {
  pname = "qofonoext";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "libqofonoext";
    rev = "1893185f2124ef5487fc684f9e69237b8551f4c4";
    hash = "sha256-mkoo0OJK7QiBmiWmklvWQO7ga8duOFkgmxzuw05vu90=";
  };

  nativeBuildInputs = [
    pkg-config
    buildPackages.qt5.qtbase.dev
  ];

  buildInputs = [
    libqofono
  ];

  depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.stdenv.cc
  ];

  dontWrapQtApps = true;

  configurePhase = ''
    runHook preConfigure

    sed -i 's@$$\[QT_INSTALL_LIBS\]@/usr/lib@g' src/src.pro
    # Cross qmake does not resolve qofono-qt5.pc reliably via PKGCONFIG.
    # Inject include/lib paths directly and drop the PKGCONFIG probes.
    sed -i '/^PKGCONFIG += qofono-qt/d' src/src.pro plugin/plugin.pro
    sed -i "1iINCLUDEPATH += ${libqofono}/usr/include/qofono-qt5" src/src.pro plugin/plugin.pro
    sed -i "1iLIBS += -L${libqofono}/usr/lib -lqofono-qt5" src/src.pro plugin/plugin.pro

    ${buildPackages.qt5.qtbase.dev}/bin/qmake src/src.pro \
      "QMAKE_CC=${stdenv.cc.targetPrefix}gcc" \
      "QMAKE_CXX=${stdenv.cc.targetPrefix}g++" \
      "QMAKE_LINK=${stdenv.cc.targetPrefix}g++" \
      "QMAKE_AR=${stdenv.cc.targetPrefix}ar cqs" \
      "QMAKE_CFLAGS+=-I${qt5.qtbase.dev}/include" \
      "QMAKE_CXXFLAGS+=-I${qt5.qtbase.dev}/include" \
      "QMAKE_INCDIR_QT=${qt5.qtbase.dev}/include" \
      "QMAKE_LIBDIR_QT=${qt5.qtbase.out}/lib" \
      "QMAKE_LIBS_QT=${qt5.qtbase.out}/lib/libQt5DBus.so ${qt5.qtbase.out}/lib/libQt5Core.so -lpthread"

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
    description = "Qt bindings for Sailfish ofono extensions";
    homepage = "https://github.com/sailfishos/libqofonoext";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
