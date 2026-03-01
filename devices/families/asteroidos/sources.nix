{ fetchFromGitHub, fetchgit }:
let
  generated = import ../../../_sources/generated.nix {
    inherit fetchgit fetchFromGitHub;
    fetchurl = null;
    dockerTools = null;
  };
in
{
  asteroidosMetaSmartwatch = generated."asteroidos-meta-smartwatch".src;
  asteroidosMetaAsteroid = generated."asteroidos-meta-asteroid".src;
  asteroidosAsteroidLauncher = generated."asteroidos-asteroid-launcher".src;
  asteroidosAsteroidHrm = generated."asteroidos-asteroid-hrm".src;
  asteroidosAsteroidCompass = generated."asteroidos-asteroid-compass".src;
  asteroidosAsteroidCalculator = generated."asteroidos-asteroid-calculator".src;
  asteroidosAsteroidCalendar = generated."asteroidos-asteroid-calendar".src;
  asteroidosAsteroidDiamonds = generated."asteroidos-asteroid-diamonds".src;
  asteroidosAsteroidFlashlight = generated."asteroidos-asteroid-flashlight".src;
  asteroidosAsteroidMusic = generated."asteroidos-asteroid-music".src;
  asteroidosAsteroidStopwatch = generated."asteroidos-asteroid-stopwatch".src;
  asteroidosAsteroidTimer = generated."asteroidos-asteroid-timer".src;
  asteroidosAsteroidWeather = generated."asteroidos-asteroid-weather".src;
  asteroidosQmlAsteroid = generated."asteroidos-qml-asteroid".src;
  asteroidosLipstick = generated."asteroidos-lipstick".src;
  merHybrisBluebinder = generated."mer-hybris-bluebinder".src;
  merHybrisQt5QpaHwcomposerPlugin = generated."mer-hybris-qt5-qpa-hwcomposer-plugin".src;
  fossilKernelMsmFossilCw = generated."fossil-kernel-msm-fossil-cw".src;
  droidianKernelLenovoBronco = generated."droidian-kernel-lenovo-bronco".src;
  droidianAdaptationLenovoBronco = generated."droidian-adaptation-lenovo-bronco".src;
  postmarketosPmaports = generated."postmarketos-pmaports".src;
}
