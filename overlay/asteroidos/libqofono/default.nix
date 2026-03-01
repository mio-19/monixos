{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  qt5,
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
    qt5.qmake
  ];

  buildInputs = [
    qt5.qtbase
  ];

  dontWrapQtApps = true;

  configurePhase = ''
    runHook preConfigure

    sed -i 's@$$\[QT_INSTALL_LIBS\]@/usr/lib@g' src/src.pro
    sed -i 's@pkgconfig-qt$${QT_MAJOR_VERSION}@pkgconfig@g' src/src.pro
    sed -i 's@$$\[QT_INSTALL_PREFIX\]/share/qt$${QT_MAJOR_VERSION}/mkspecs/features@/usr/lib/qt5/mkspecs/features@g' src/src.pro

    qmake src/src.pro

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
