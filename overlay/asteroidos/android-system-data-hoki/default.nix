{
  lib,
  stdenv,
  fetchurl,
}:

stdenv.mkDerivation {
  pname = "android-system-data-hoki";
  version = "pie";

  src = fetchurl {
    # Matches upstream meta-hoki android-system-data_hoki-p recipe.
    url = "https://dl.dropboxusercontent.com/s/1mmpew8kyn52jko/system-hoki-p.tar.gz";
    hash = "sha256-FBagGo/RnpyCqgypveM9toU+sI9UEVkrSxeDZJcUF84=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -d $out/system
    cp -r system/* $out/system/

    install -d $out/vendor
    cp -r vendor/* $out/vendor/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Fossil Gen 6 Android system/vendor blobs for AsteroidOS-compatible userspace";
    homepage = "https://github.com/AsteroidOS/meta-smartwatch";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
