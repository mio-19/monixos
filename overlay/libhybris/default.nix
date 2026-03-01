{
stdenv
, lib
, fetchFromGitHub
, autoreconfHook
, pkg-config

, android-headers
, file
}:

let
  inherit (stdenv) targetPlatform buildPlatform;
  libPrefix = if targetPlatform == buildPlatform then ""
    else stdenv.targetPlatform.config;
in
stdenv.mkDerivation {
  pname = "libhybris";
  version = "unstable-2026-03-01";

  src = fetchFromGitHub {
    owner = "libhybris";
    repo = "libhybris";
    rev = "69fe409485f3bd815d03d895209b6d3548d44299";
    hash = "sha256-r7gabMv+4tJBrAu62LiqGNCEm64eGHvrHhxCqoLzc4A=";
  };

  patches = [ ];

  postAutoreconf = ''
    substituteInPlace configure \
      --replace "/usr/bin/file" "${file}/bin/file"
  '';

  NIX_CFLAGS_COMPILE = [
    # Upstream still emits warnings that break with modern toolchains.
    "-Wno-implicit-function-declaration"
    "-Wno-incompatible-pointer-types"
    "-Wno-int-conversion"
  ];
  NIX_LDFLAGS = [
    # For libsupc++.a
    "-L${stdenv.cc.cc.out}/${libPrefix}/lib/"
  ];

  configureFlags = [
    "--with-android-headers=${android-headers}/include/android/"
  ]
  ++ lib.optional targetPlatform.isAarch64 "--enable-arch=arm64"
  ++ lib.optional targetPlatform.isAarch32 "--enable-arch=arm"
  ;

  sourceRoot = "source/hybris";

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];
}
