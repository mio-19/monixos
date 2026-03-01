{
  lib,
  stdenv,
  buildPackages,
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
    buildPackages.qt5.qtbase.dev
  ];

  buildInputs = [
    glib
    (lib.getDev glib)
    libgbinder
    (lib.getDev libgbinder)
    libglibutil
    (lib.getDev libglibutil)
    libqofono
    qofonoext
    libconnman-qt5
  ];

  depsBuildBuild = lib.optionals (stdenv.buildPlatform != stdenv.hostPlatform) [
    buildPackages.stdenv.cc
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
# Avoid qmake PKGCONFIG checks for Qt phone stack dependencies in cross builds.
sed -i '/^PKGCONFIG += connman-qt5 qofono-qt5 qofonoext systemsettings$/d' geoclue-providers-hybris.pri
sed -i '/^PKGCONFIG += libgbinder libglibutil gobject-2.0 glib-2.0$/d' binder/binderlocationbackend.pro
cat >> geoclue-providers-hybris.pri <<EOF
INCLUDEPATH += ${libconnman-qt5}/usr/include/connman-qt5
LIBS += -L${libconnman-qt5}/usr/lib -lconnman-qt5
INCLUDEPATH += ${libqofono}/usr/include/qofono-qt5
LIBS += -L${libqofono}/usr/lib -lqofono-qt5
INCLUDEPATH += ${qofonoext}/usr/include/qofonoext
LIBS += -L${qofonoext}/usr/lib -lqofonoext
INCLUDEPATH += ${lib.getDev libgbinder}/include/gbinder
LIBS += -L${libgbinder}/lib -lgbinder
INCLUDEPATH += ${lib.getDev libglibutil}/include/gutil
LIBS += -L${libglibutil}/lib -lglibutil
INCLUDEPATH += ${lib.getDev glib}/include/glib-2.0 ${lib.getLib glib}/lib/glib-2.0/include
LIBS += -L${lib.getLib glib}/lib -lglib-2.0 -lgobject-2.0
EOF
perl -0pi -e 's@void HybrisProvider::setLocationSettings\(LocationSettings \*settings\)\n\{.*?\n\}\n\nvoid HybrisProvider::AddReference@void HybrisProvider::setLocationSettings(LocationSettings *settings)\n{\n    if (!m_locationSettings)\n        m_locationSettings = settings;\n}\n\nvoid HybrisProvider::AddReference@s' hybrisprovider.cpp
  '';

  configurePhase = ''
    runHook preConfigure
    export PKG_CONFIG_PATH="${lib.getDev glib}/lib/pkgconfig:${lib.getDev libgbinder}/lib/pkgconfig:${lib.getDev libglibutil}/lib/pkgconfig:${libqofono}/usr/lib/pkgconfig:${qofonoext}/usr/lib/pkgconfig:${libconnman-qt5}/usr/lib/pkgconfig''${PKG_CONFIG_PATH:+:$PKG_CONFIG_PATH}"
    ${buildPackages.qt5.qtbase.dev}/bin/qmake binder/binderlocationbackend.pro \
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
    runHook postInstall
  '';

  meta = with lib; {
    description = "Binder-based hybris backend for geoclue";
    homepage = "https://github.com/mer-hybris/geoclue-providers-hybris";
    license = licenses.lgpl21Plus;
    platforms = platforms.linux;
  };
}
