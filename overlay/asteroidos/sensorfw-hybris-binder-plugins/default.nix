{
  lib,
  stdenv,
  buildPackages,
  fetchFromGitHub,
  pkg-config,
  qt5,
  glib,
  libgbinder,
  libglibutil,
  sensorfw,
}:

stdenv.mkDerivation rec {
  pname = "sensorfw-hybris-binder-plugins";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "sailfishos";
    repo = "sensorfw";
    rev = "b62d0e591d736c904128fcfc8476f22cfdbe53b9";
    hash = "sha256-+rTwVJSaYAV7lCUPISxtlPZvRyIeFiAgsdOfuBat98k=";
  };

  nativeBuildInputs = [
    pkg-config
    buildPackages.qt5.qtbase.dev
  ];

  buildInputs = [
    glib
    libgbinder
    libglibutil
  ];
  depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.stdenv.cc
  ];
  dontWrapQtApps = true;

  propagatedBuildInputs = [ sensorfw ];

  configurePhase = ''
    runHook preConfigure

    sed "s=@LIB@=lib/=g" sensord-qt5.pc.in > sensord-qt5.pc
    sed -i 's@\$\$\[QT_INSTALL_LIBS\]@/usr/lib@g' common-install.pri core/core.pro core/hybris.pro sensord.prf sensorfw.pro
    sed -i 's@\$\$\[QT_INSTALL_ARCHDATA\]@/usr/lib/qt5@g' sensorfw.pro
    sed -i '/include( doc\/doc.pri )/d' sensorfw.pro
    sed -i '/tests \\/d' sensorfw.pro
    sed -i '/examples$/d' sensorfw.pro

    qmake sensorfw.pro CONFIG+=config_hybris CONFIG+=binder

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

    # Keep only the hybris plugin artifacts, matching upstream package split.
    find "$out" -mindepth 1 -maxdepth 1 -type d ! -name usr -exec rm -rf '{}' +
    find "$out/usr" -mindepth 1 -maxdepth 1 -type d ! -name lib -exec rm -rf '{}' +
    find "$out/usr/lib" -mindepth 1 -maxdepth 1 ! -name 'sensord-qt5' ! -name 'libhybris*' -exec rm -rf '{}' +
    find "$out/usr/lib/sensord-qt5" -mindepth 1 -maxdepth 1 ! -name 'libhybris*' -exec rm -rf '{}' +

    runHook postInstall
  '';

  meta = with lib; {
    description = "Hybris binder plugins for sensorfw";
    homepage = "https://github.com/sailfishos/sensorfw";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
