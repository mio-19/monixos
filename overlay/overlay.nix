final: super:

let
  callPackage = final.callPackage;
  isCross = final.stdenv.buildPlatform.config != final.stdenv.hostPlatform.config;
  withScopedQmake = qmakeHook: drv:
    drv.overrideAttrs (old: {
      nativeBuildInputs = builtins.map
        (input:
          let
            inputName = (input.pname or input.name or "");
          in
          if final.lib.hasPrefix "qmake-hook" inputName then qmakeHook else input
        )
        old.nativeBuildInputs;
    });
  relaxedCrossQtbaseHook = qtbaseDrv:
    qtbaseDrv.overrideAttrs (old: {
      setupHook = final.writeText "qtbase-setup-hook.sh" (
        builtins.replaceStrings
          [
            "        echo >&2 \"Error: detected mismatched Qt dependencies:\"\n        echo >&2 \"    @dev@\"\n        echo >&2 \"    $__nix_qtbase\"\n        exit 1\n"
          ]
          [
            "        echo >&2 \"Error: detected mismatched Qt dependencies:\"\n        echo >&2 \"    @dev@\"\n        echo >&2 \"    $__nix_qtbase\"\n        # Allow the expected host-vs-target Qt split in cross builds.\n        if [[ \"$__nix_qtbase\" != \"${super.pkgsBuildHost.qt5.qtbase.dev}\" ]]; then\n            exit 1\n        fi\n"
          ]
          (builtins.readFile old.setupHook)
      );
    });
  fixQtDeclarativeQmlPrefix = qtQmlPrefix: qtdeclarativeDrv:
    qtdeclarativeDrv.overrideAttrs (old: {
      postPatch = (old.postPatch or "") + ''
        substituteInPlace src/qml/qml/qqmlimport.cpp \
          --replace-fail 'QStringLiteral("../" NIXPKGS_QML2_IMPORT_PREFIX);' \
                         'QStringLiteral("../${qtQmlPrefix}");'
      '';
    });
in
  {
    # Misc. tools.
    # Keep sorted.
    adbd = callPackage ./adbd { };
    android-headers = callPackage ./android-headers { };
    dtbTool = callPackage ./dtbtool { };
    dtbTool-exynos = callPackage ./dtbtool-exynos { };
    libhybris = callPackage ./libhybris { };
    mkbootimg = callPackage ./mkbootimg { };
    msm-fb-refresher = callPackage ./msm-fb-refresher { };
    ply-image = callPackage ./ply-image { };
    qc-image-unpacker = callPackage ./qc-image-unpacker { };
    ufdt-apply-overlay = callPackage ./ufdt-apply-overlay {};

    # Extra "libs"
    mkExtraUtils = import ./lib/extra-utils.nix {
      inherit (final)
        runCommandCC
        glibc
        buildPackages
      ;
      inherit (final.buildPackages)
        nukeReferences
      ;
    };

    #
    # New software to upstream
    # ------------------------
    #

    android-partition-tools = callPackage ./android-partition-tools {
      stdenv = with final; overrideCC stdenv buildPackages.clang;
    };
    make_ext4fs = callPackage ./make_ext4fs {};
    hardshutdown = callPackage ./hardshutdown {};
    bootlogd = callPackage ./bootlogd {};
    libusbgx = callPackage ./libusbgx {};
    gadget-tool = callPackage ./gt {}; # upstream this is called "gt", which is very Unix.

    qrtr = callPackage ./qrtr/qrtr.nix { };
    qmic = callPackage ./qrtr/qmic.nix { };
    tqftpserv = callPackage ./qrtr/tqftpserv.nix { };
    pd-mapper = callPackage ./qrtr/pd-mapper.nix { };
    rmtfs = callPackage ./qrtr/rmtfs.nix { };

    lk2ndMsm8953 = callPackage ./lk2nd/msm8953.nix {};

    #
    # Hacks
    # -----
    #
    # Totally not upstreamable stuff.
    #

    xf86-video-fbdev = super.xf86-video-fbdev.overrideAttrs({patches ? [], ...}: {
      patches = patches ++ [
        ./xserver/0001-HACK-fbdev-don-t-bail-on-mode-initialization-fail.patch
      ];
    });

    #
    # Fixes to upstream
    # -----------------
    #
    # All that follows will have to be cleaned and then upstreamed.
    #
    qt5 = if isCross then super.qt5.overrideScope (_: qtPrev: {
      qtbase = relaxedCrossQtbaseHook qtPrev.qtbase;
      qtdeclarative = fixQtDeclarativeQmlPrefix qtPrev.qtbase.qtQmlPrefix qtPrev.qtdeclarative;
    }) else super.qt5;

    libsForQt5 = if isCross then super.libsForQt5.overrideScope (_: qtPrev: {
      qtbase = relaxedCrossQtbaseHook qtPrev.qtbase;
      qtdeclarative = fixQtDeclarativeQmlPrefix qtPrev.qtbase.qtQmlPrefix qtPrev.qtdeclarative;
    }) else super.libsForQt5;

    pkgsBuildHost =
      if isCross then
        super.pkgsBuildHost // {
          qt5 = super.pkgsBuildHost.qt5.overrideScope (_: qtPrev: {
            qtsvg = withScopedQmake super.pkgsBuildHost.qt5.qmake qtPrev.qtsvg;
            qtdeclarative = withScopedQmake super.pkgsBuildHost.qt5.qmake (fixQtDeclarativeQmlPrefix qtPrev.qtbase.qtQmlPrefix qtPrev.qtdeclarative);
            qttools = withScopedQmake super.pkgsBuildHost.qt5.qmake qtPrev.qttools;
            qtquickcontrols = withScopedQmake super.pkgsBuildHost.qt5.qmake qtPrev.qtquickcontrols;
            qtwayland = withScopedQmake super.pkgsBuildHost.qt5.qmake qtPrev.qtwayland;
          });
          libsForQt5 = super.pkgsBuildHost.libsForQt5.overrideScope (_: qtPrev: {
            qtsvg = withScopedQmake super.pkgsBuildHost.libsForQt5.qmake qtPrev.qtsvg;
            qtdeclarative = withScopedQmake super.pkgsBuildHost.libsForQt5.qmake (fixQtDeclarativeQmlPrefix qtPrev.qtbase.qtQmlPrefix qtPrev.qtdeclarative);
            qttools = withScopedQmake super.pkgsBuildHost.libsForQt5.qmake qtPrev.qttools;
            qtquickcontrols = withScopedQmake super.pkgsBuildHost.libsForQt5.qmake qtPrev.qtquickcontrols;
            qtwayland = withScopedQmake super.pkgsBuildHost.libsForQt5.qmake qtPrev.qtwayland;
          });
        }
      else
        super.pkgsBuildHost;

    sbc =
      if final.stdenv.hostPlatform.system == "armv7l-linux" then
        super.sbc.overrideAttrs (old: {
          # GCC's newer default C mode rejects the armv6 "naked" helper calls used by sbc.
          # Keep the older C semantics on armv7 targets.
          NIX_CFLAGS_COMPILE = (old.NIX_CFLAGS_COMPILE or "") + " -std=gnu17";
        })
      else
        super.sbc;

    # Things specific to mobile-nixos.
    # Not necessarily internals, but they probably won't go into <nixpkgs>.
    mobile-nixos = {
      kernel-builder = callPackage ./mobile-nixos/kernel/builder.nix {};
      kernel-builder-clang = callPackage ./mobile-nixos/kernel/builder.nix {
        stdenv = with final; overrideCC stdenv buildPackages.clang;
      };

      # We need to "globally" locally override some packages for stage-1.
      stage-1 = (final.appendOverlays [(import ../boot/overlay)]).mobile-nixos.stage-1;

      # Originally part of `stage-1`.
      # In stage-1 it is now overridden with the cut-down libinput and libxkbcommon.
      script-loader = callPackage ../boot/script-loader {};

      # Flashable zip binaries are always static.
      android-flashable-zip-binaries = final.pkgsStatic.callPackage ./mobile-nixos/android-flashable-zip-binaries {};

      autoport = callPackage ./mobile-nixos/autoport {};

      boot-control = callPackage ./mobile-nixos/boot-control {};

      boot-recovery-menu-simulator = final.mobile-nixos.stage-1.boot-recovery-menu.simulator;
      boot-splash-simulator = final.mobile-nixos.stage-1.boot-splash.simulator;

      fdt-forward = callPackage ./mobile-nixos/fdt-forward {};

      gui-assets = callPackage ./mobile-nixos/gui-assets {};

      make-flashable-zip = callPackage ./mobile-nixos/android-flashable-zip/make-flashable-zip.nix {};

      map-dtbs = callPackage ./mobile-nixos/map-dtbs {};

      mkLVGUIApp = callPackage ./mobile-nixos/lvgui {};

      cross-canary-test = callPackage ./mobile-nixos/cross-canary/test.nix {};
      cross-canary-test-static = final.pkgsStatic.callPackage ./mobile-nixos/cross-canary/test.nix {};

      pine64-alsa-ucm = callPackage ./mobile-nixos/pine64-alsa-ucm {};
    };

    image-builder = callPackage ./image-builder {};
 }
