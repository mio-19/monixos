{
  lib,
  stdenv,
  asteroidosMetaSmartwatch,
}:

stdenv.mkDerivation {
  pname = "hoki-initramfs-machine";
  version = "unstable-2026-03-01";
  src = asteroidosMetaSmartwatch;

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 \
      $src/meta-hoki/recipes-core/initrdscripts/initramfs-scripts-android/init.machine.sh \
      $out/init.machine

    install -Dm644 \
      $src/meta-hoki/recipes-core/initrdscripts/initramfs-scripts-android/machine.conf \
      $out/etc/asteroid/machine.conf

    runHook postInstall
  '';

  meta = with lib; {
    description = "AsteroidOS hoki initramfs machine hook and machine config";
    homepage = "https://github.com/AsteroidOS/meta-smartwatch";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
  };
}
