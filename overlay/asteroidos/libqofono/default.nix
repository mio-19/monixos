{
  lib,
  stdenv,
  buildPackages,
  fetchFromGitHub,
  pkg-config,
  qt5,
  libglvnd,
}:

stdenv.mkDerivation rec {
  pname = "libqofono";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "libqofono";
    rev = "40c7ccfddae6f414ce95e27fd70c35d1d758ddf3";
    hash = "sha256-fI7RS0V8wrsJ2AZAyjVgHmG+c13DXdo6xTjIlGbOHI8=";
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

    sed -i 's@$$\[QT_INSTALL_LIBS\]@/usr/lib@g' src/src.pro
    sed -i 's@pkgconfig-qt$${QT_MAJOR_VERSION}@pkgconfig@g' src/src.pro
    sed -i 's@$$\[QT_INSTALL_PREFIX\]/share/qt$${QT_MAJOR_VERSION}/mkspecs/features@/usr/lib/qt5/mkspecs/features@g' src/src.pro

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
    sed -i "s|${buildPackages.libglvnd}|${libglvnd}|g" Makefile

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
    description = "Qt bindings for ofono";
    homepage = "https://github.com/sailfishos/libqofono";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
