{
  lib,
  stdenv,
  fetchFromGitHub,
  kernelPackage,
  asteroidosMetaSmartwatch,
}:

stdenv.mkDerivation rec {
  pname = "linux-audio-modules-hoki";
  version = "4.9+pie";

  src = fetchFromGitHub {
    owner = "fossil-engineering";
    repo = "kernel-msm-fossil-extra-cw-audiokernel";
    rev = "c984389253fc58bc316af06bf3504dd2c25382be";
    hash = "sha256-2YqQ/B7WoTIkmvuDQ+XFtMMKJ4pf2DoSgwZ5xg4dP6E=";
  };

  patches = [
    "${asteroidosMetaSmartwatch}/meta-hoki/recipes-kernel/modules/linux-audio-modules-hoki/0001-Remove-export-from-Kbuild-files.patch"
    "${asteroidosMetaSmartwatch}/meta-hoki/recipes-kernel/modules/linux-audio-modules-hoki/0002-Avoid-shell-expansion-in-recursively-expanded-variab.patch"
    "${asteroidosMetaSmartwatch}/meta-hoki/recipes-kernel/modules/linux-audio-modules-hoki/0003-Import-beluga-makefile.patch"
    "${asteroidosMetaSmartwatch}/meta-hoki/recipes-kernel/modules/linux-audio-modules-hoki/0004-Ignore-compilation-warnings.patch"
    "${asteroidosMetaSmartwatch}/meta-hoki/recipes-kernel/modules/linux-audio-modules-hoki/0005-dsp-Compile-codecs-for-out-of-tree-builds.patch"
  ];

  enableParallelBuilding = false;

  buildPhase = ''
    runHook preBuild
    make KERNEL_SRC=${kernelPackage.dev}/lib/modules/${kernelPackage.modDirVersion}/build M=$PWD
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    modDir=$out/lib/modules/${kernelPackage.modDirVersion}/extra
    mkdir -p "$modDir"

    # Keep module tree shallow and explicit for predictable modprobe behavior.
    find . -type f -name '*.ko' -print0 | while IFS= read -r -d '' ko; do
      cp -v "$ko" "$modDir/"
    done

    runHook postInstall
  '';

  meta = with lib; {
    description = "Out-of-tree Fossil Gen 6 audio kernel modules used by upstream AsteroidOS";
    homepage = "https://github.com/fossil-engineering/kernel-msm-fossil-extra-cw-audiokernel";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
