{
  pkgs,
  sources,
}:
let
  inherit (sources)
    asteroidosMetaSmartwatch
    asteroidosMetaAsteroid
    asteroidosAsteroidHrm
    asteroidosAsteroidCompass
    asteroidosAsteroidCalculator
    asteroidosAsteroidCalendar
    asteroidosAsteroidDiamonds
    asteroidosAsteroidFlashlight
    asteroidosAsteroidMusic
    asteroidosAsteroidStopwatch
    asteroidosAsteroidTimer
    asteroidosAsteroidWeather
    asteroidosQmlAsteroid
    merHybrisBluebinder
    merHybrisQt5QpaHwcomposerPlugin
  ;
  qmlAsteroid = pkgs.callPackage ../../../overlay/asteroidos/qml-asteroid {
    inherit asteroidosQmlAsteroid;
  };
in
rec
{
  metaSmartwatchSrc = asteroidosMetaSmartwatch;
  qml-asteroid = qmlAsteroid;
  bluebinder = pkgs.callPackage ../../../overlay/asteroidos/bluebinder {
    inherit merHybrisBluebinder;
  };
  "qt5-qpa-hwcomposer-plugin" = pkgs.callPackage ../../../overlay/asteroidos/qt5-qpa-hwcomposer-plugin {
    inherit merHybrisQt5QpaHwcomposerPlugin;
  };
  hoki-underclock = pkgs.callPackage ../../../overlay/asteroidos/hoki-underclock {
    inherit asteroidosMetaSmartwatch;
  };
  "android-init-hoki" = pkgs.callPackage ../../../overlay/asteroidos/android-init-hoki {
    inherit asteroidosMetaSmartwatch asteroidosMetaAsteroid;
  };
  libdbusaccess = pkgs.callPackage ../../../overlay/asteroidos/libdbusaccess { };
  libncicore = pkgs.callPackage ../../../overlay/asteroidos/libncicore {
    inherit asteroidosMetaAsteroid;
  };
  nfcd = pkgs.callPackage ../../../overlay/asteroidos/nfcd {
    inherit asteroidosMetaAsteroid;
    inherit libdbusaccess;
  };
  libnciplugin = pkgs.callPackage ../../../overlay/asteroidos/libnciplugin {
    inherit asteroidosMetaAsteroid;
    inherit nfcd libncicore;
  };
  "nfcd-binder-plugin" = pkgs.callPackage ../../../overlay/asteroidos/nfcd-binder-plugin {
    inherit asteroidosMetaAsteroid;
    inherit nfcd libncicore libnciplugin;
  };
  "udev-droid-system" = pkgs.callPackage ../../../overlay/asteroidos/udev-droid-system {
    inherit asteroidosMetaAsteroid;
  };
  "swclock-offset" = pkgs.callPackage ../../../overlay/asteroidos/swclock-offset { };
  "hoki-launcher-config" = pkgs.callPackage ../../../overlay/asteroidos/hoki-launcher-config {
    inherit asteroidosMetaSmartwatch;
  };
  "hoki-libncicore-config" = pkgs.callPackage ../../../overlay/asteroidos/hoki-libncicore-config {
    inherit asteroidosMetaSmartwatch;
  };
  "hoki-ngfd-config" = pkgs.callPackage ../../../overlay/asteroidos/hoki-ngfd-config {
    inherit asteroidosMetaSmartwatch;
  };
  "hoki-initramfs-machine" = pkgs.callPackage ../../../overlay/asteroidos/hoki-initramfs-machine {
    inherit asteroidosMetaSmartwatch;
  };
  "android-system-data-hoki" = pkgs.callPackage ../../../overlay/asteroidos/android-system-data-hoki { };
  libqofono = pkgs.callPackage ../../../overlay/asteroidos/libqofono { };
  qofonoext = pkgs.callPackage ../../../overlay/asteroidos/qofonoext {
    inherit libqofono;
  };
  libconnman-qt5 = pkgs.callPackage ../../../overlay/asteroidos/libconnman-qt5 { };
  "geoclue-provider-hybris-binder" = pkgs.callPackage ../../../overlay/asteroidos/geoclue-provider-hybris-binder {
    inherit libqofono qofonoext libconnman-qt5;
  };
  sensorfw = pkgs.callPackage ../../../overlay/asteroidos/sensorfw { };
  "sensorfw-hybris-binder-plugins" = pkgs.callPackage ../../../overlay/asteroidos/sensorfw-hybris-binder-plugins {
    inherit sensorfw;
  };
  "asteroid-hrm" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-hrm {
    inherit asteroidosAsteroidHrm;
    inherit qmlAsteroid;
  };
  "asteroid-compass" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-compass {
    inherit asteroidosAsteroidCompass;
    inherit qmlAsteroid;
  };
  "asteroid-calculator" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-calculator";
    src = asteroidosAsteroidCalculator;
    inherit qmlAsteroid;
    description = "AsteroidOS calculator app";
    homepage = "https://github.com/AsteroidOS/asteroid-calculator";
  };
  "asteroid-calendar" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-calendar";
    src = asteroidosAsteroidCalendar;
    inherit qmlAsteroid;
    description = "AsteroidOS calendar app";
    homepage = "https://github.com/AsteroidOS/asteroid-calendar";
  };
  "asteroid-diamonds" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-diamonds";
    src = asteroidosAsteroidDiamonds;
    inherit qmlAsteroid;
    description = "AsteroidOS diamonds game";
    homepage = "https://github.com/AsteroidOS/asteroid-diamonds";
  };
  "asteroid-flashlight" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-flashlight";
    src = asteroidosAsteroidFlashlight;
    inherit qmlAsteroid;
    description = "AsteroidOS flashlight app";
    homepage = "https://github.com/AsteroidOS/asteroid-flashlight";
  };
  "asteroid-music" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-music";
    src = asteroidosAsteroidMusic;
    inherit qmlAsteroid;
    description = "AsteroidOS music app";
    homepage = "https://github.com/AsteroidOS/asteroid-music";
  };
  "asteroid-stopwatch" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-stopwatch";
    src = asteroidosAsteroidStopwatch;
    inherit qmlAsteroid;
    description = "AsteroidOS stopwatch app";
    homepage = "https://github.com/AsteroidOS/asteroid-stopwatch";
  };
  "asteroid-timer" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-timer";
    src = asteroidosAsteroidTimer;
    inherit qmlAsteroid;
    description = "AsteroidOS timer app";
    homepage = "https://github.com/AsteroidOS/asteroid-timer";
  };
  "asteroid-weather" = pkgs.callPackage ../../../overlay/asteroidos/asteroid-qml-app {
    pname = "asteroid-weather";
    src = asteroidosAsteroidWeather;
    inherit qmlAsteroid;
    description = "AsteroidOS weather app";
    homepage = "https://github.com/AsteroidOS/asteroid-weather";
  };
}
