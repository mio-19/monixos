{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  perl,
  qt5,
  glib,
  libgbinder,
  libglibutil,
  libqofono,
  qofonoext,
  libconnman-qt5,
}:

stdenv.mkDerivation rec {
  pname = "geoclue-provider-hybris-binder";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "mer-hybris";
    repo = "geoclue-providers-hybris";
    rev = "6d13f895354b12add997d4a6b737e8f211237e21";
    hash = "sha256-REXybN5lsF2YoPqBJabQIRzdqams7VE27w5wUUKXUSg=";
  };

  nativeBuildInputs = [
    pkg-config
    perl
    qt5.qmake
  ];

  buildInputs = [
    qt5.qtbase
    glib
    libgbinder
    libglibutil
    libqofono
    qofonoext
    libconnman-qt5
  ];

  dontWrapQtApps = true;

  postPatch = ''
    # mobile-nixos currently doesn't package Sailfish systemsettings;
    # provide a minimal always-enabled LocationSettings implementation.
    cat > locationsettings.h <<'STUB'
    #pragma once
    #include <QObject>

    class LocationSettings : public QObject {
    public:
      enum HereState { HereOff = 0, OnlineAGpsEnabled = 1 };
      enum DataSource { GpsData = 1 };
      Q_DECLARE_FLAGS(DataSources, DataSource)

      explicit LocationSettings(QObject *parent = nullptr)
        : QObject(parent) {}

      bool locationEnabled() const { return true; }
      bool gpsAvailable() const { return true; }
      bool gpsEnabled() const { return true; }
      bool gpsFlightMode() const { return false; }
      int allowedDataSources() const { return int(GpsData); }

      bool hereAvailable() const { return false; }
      HereState hereState() const { return HereOff; }

      bool mlsAvailable() const { return false; }
      bool mlsEnabled() const { return false; }
      HereState mlsOnlineState() const { return HereOff; }
    };

    Q_DECLARE_OPERATORS_FOR_FLAGS(LocationSettings::DataSources)
    STUB

    sed -i 's@<locationsettings.h>@"locationsettings.h"@' main.cpp hybrisprovider.h
    sed -i 's@ connman-qt5 qofono-qt5 qofonoext systemsettings@ connman-qt5 qofono-qt5 qofonoext@' geoclue-providers-hybris.pri
    perl -0pi -e 's@void HybrisProvider::setLocationSettings\(LocationSettings \*settings\)\n\{.*?\n\}\n\nvoid HybrisProvider::AddReference@void HybrisProvider::setLocationSettings(LocationSettings *settings)\n{\n    if (!m_locationSettings)\n        m_locationSettings = settings;\n}\n\nvoid HybrisProvider::AddReference@s' hybrisprovider.cpp
  '';

  configurePhase = ''
    runHook preConfigure
    export PKG_CONFIG_PATH="${libqofono}/usr/lib/pkgconfig:${qofonoext}/usr/lib/pkgconfig:${libconnman-qt5}/usr/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    qmake binder/binderlocationbackend.pro
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

  meta = with lib; {
    description = "Binder-based hybris backend for geoclue";
    homepage = "https://github.com/mer-hybris/geoclue-providers-hybris";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
