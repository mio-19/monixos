{ lib
, stdenv
, buildPackages
, pkg-config
, qt5
, libhybris
, android-headers
, libdrm
, merHybrisQt5QpaHwcomposerPlugin
}:

stdenv.mkDerivation rec {
  pname = "qt5-qpa-hwcomposer-plugin";
  version = "unstable-2026-02-24";
  src = merHybrisQt5QpaHwcomposerPlugin;

  nativeBuildInputs = [
    pkg-config
    buildPackages.perl
    buildPackages.qt5.qtbase.dev
  ];

  depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.stdenv.cc
  ];

  buildInputs = [
    qt5.qtbase
    libhybris
    android-headers
    libdrm
  ];

  configurePhase = ''
    runHook preConfigure
    substituteInPlace hwcomposer/hwcomposer.pro \
      --replace-fail 'PKGCONFIG_PRIVATE += libudev glib-2.0 mtdev' "" \
      --replace-fail 'PKGCONFIG += android-headers libhardware hybris-egl-platform' \
                     'LIBS += -L${libhybris}/lib -lhardware -lhybris-eglplatformcommon' \
      --replace-fail '        QT += egl_support-private waylandcompositor-private fontdatabase_support-private eventdispatcher_support-private theme_support-private' \
                     '        QT += egl_support-private' \
      --replace-fail '        QT += compositor-private platformsupport-private' ""
    substituteInPlace hwcomposer/config.tests/hwcomposer2/hwcomposer2.pro \
      --replace-fail 'PKGCONFIG += android-headers' ""

    ${buildPackages.qt5.qtbase.dev}/bin/qmake hwcomposer.pro \
      "QMAKE_CC=${stdenv.cc.targetPrefix}gcc" \
      "QMAKE_CXX=${stdenv.cc.targetPrefix}g++" \
      "QMAKE_LINK=${stdenv.cc.targetPrefix}g++" \
      "QMAKE_AR=${stdenv.cc.targetPrefix}ar cqs" \
      "QMAKE_CFLAGS+=-I${qt5.qtbase.dev}/include" \
      "QMAKE_CXXFLAGS+=-I${qt5.qtbase.dev}/include" \
      "QMAKE_CFLAGS+=-I${android-headers}/include -I${android-headers}/include/android" \
      "QMAKE_CXXFLAGS+=-I${android-headers}/include -I${android-headers}/include/android" \
      "QMAKE_CFLAGS+=-I${libhybris}/include" \
      "QMAKE_CXXFLAGS+=-I${libhybris}/include" \
      "QMAKE_INCDIR_QT=${qt5.qtbase.dev}/include" \
      "QMAKE_LIBDIR_QT=${qt5.qtbase.out}/lib"
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
    runHook postInstall
  '';

  dontWrapQtApps = true;

  meta = with lib; {
    description = "Qt QPA hwcomposer platform plugin used by AsteroidOS/Lipstick";
    homepage = "https://github.com/mer-hybris/qt5-qpa-hwcomposer-plugin";
    license = licenses.lgpl21Only;
    platforms = platforms.linux;
  };
}
