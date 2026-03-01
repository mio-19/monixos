{
  lib,
  stdenv,
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
    qt5.qmake
  ];

  buildInputs = [
    qt5.qtbase
    libqofono
  ];

  dontWrapQtApps = true;

  configurePhase = ''
    runHook preConfigure

    sed -i 's@$$\[QT_INSTALL_LIBS\]@/usr/lib@g' src/src.pro
    export PKG_CONFIG_PATH="${libqofono}/usr/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"

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
    description = "Qt bindings for Sailfish ofono extensions";
    homepage = "https://github.com/sailfishos/libqofonoext";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
