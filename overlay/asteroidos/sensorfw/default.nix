{
  lib,
  stdenv,
  buildPackages,
  fetchFromGitHub,
  pkg-config,
  qt5,
  systemd,
}:

stdenv.mkDerivation rec {
  pname = "sensorfw";
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
    systemd
  ];
  depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.stdenv.cc
  ];
  dontWrapQtApps = true;

  configurePhase = ''
    runHook preConfigure

    sed "s=@LIB@=lib/=g" sensord-qt5.pc.in > sensord-qt5.pc
    sed -i 's@\$\$\[QT_INSTALL_LIBS\]@/usr/lib@g' common-install.pri core/core.pro core/hybris.pro sensord.prf sensorfw.pro
    sed -i 's@\$\$\[QT_INSTALL_ARCHDATA\]@/usr/lib/qt5@g' sensorfw.pro
    sed -i '/include( doc\/doc.pri )/d' sensorfw.pro
    sed -i '/tests \\/d' sensorfw.pro
    sed -i '/examples$/d' sensorfw.pro

    qmake sensorfw.pro CONFIG+=configs

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

    install -Dm644 rpm/sensorfwd.service "$out/lib/systemd/system/sensorfwd.service"
    mkdir -p "$out/lib/systemd/system/multi-user.target.wants"
    ln -sf ../sensorfwd.service "$out/lib/systemd/system/multi-user.target.wants/sensorfwd.service"

    mkdir -p "$out/etc/sensorfw"
    cp config/sensord-hybris.conf "$out/etc/sensorfw/primaryuse.conf"

    runHook postInstall
  '';

  meta = with lib; {
    description = "Nemomobile sensor framework (sensord + libraries)";
    homepage = "https://github.com/sailfishos/sensorfw";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
