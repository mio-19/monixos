{
  config,
  lib,
  pkgs,
  asteroidosPackages,
  ...
}:
let
  includeAndroidSystemData = true;
  missingParityPkgs =
    builtins.filter
      (name: !(builtins.hasAttr name pkgs))
      [ ];
  audioModules =
    pkgs.callPackage ../../../overlay/asteroidos/linux-audio-modules-hoki {
      kernelPackage = config.mobile.boot.stage-1.kernel.package;
      asteroidosMetaSmartwatch = asteroidosPackages.metaSmartwatchSrc;
    };
  optionalPkgs =
    builtins.filter
      (name: builtins.hasAttr name pkgs)
      [
        # Upstream meta-hoki machine extras.
        "qrtr"
      ];
in
{
  nixpkgs.config.allowUnfree = lib.mkDefault true;

  warnings =
    (map
      (name: "AsteroidOS hoki parity: `${name}` is not packaged in this tree yet.")
      missingParityPkgs)
    ++ lib.optionals (!config.mobile.boot.stage-1.kernel.modular) [
      "AsteroidOS hoki parity: `linux-audio-modules-hoki` is packaged but not enabled because this kernel path is non-modular."
    ];

  environment.systemPackages = [
    asteroidosPackages.hoki-underclock
    asteroidosPackages."hoki-launcher-config"
    asteroidosPackages."hoki-libncicore-config"
    asteroidosPackages."hoki-ngfd-config"
    asteroidosPackages.nfcd
    asteroidosPackages.libncicore
    asteroidosPackages.libnciplugin
    asteroidosPackages."nfcd-binder-plugin"
    asteroidosPackages.sensorfw
    asteroidosPackages."sensorfw-hybris-binder-plugins"
    asteroidosPackages."geoclue-provider-hybris-binder"
  ]
  ++ (lib.optional includeAndroidSystemData asteroidosPackages."android-system-data-hoki")
  ++ map (name: builtins.getAttr name pkgs) optionalPkgs;

  environment.etc = {
    "default/asteroid-launcher".source = "${asteroidosPackages."hoki-launcher-config"}/etc/default/asteroid-launcher";
    "libncicore.conf".source = "${asteroidosPackages."hoki-libncicore-config"}/etc/libncicore.conf";
    "ngfd/plugins.d/51-ffmemless.ini".source = "${asteroidosPackages."hoki-ngfd-config"}/share/ngfd/plugins.d/51-ffmemless.ini";
    "android-init/plat_property_contexts".source = "${asteroidosPackages."android-init-hoki"}/etc/android-init/plat_property_contexts";
    "android-init/nonplat_property_contexts".source = "${asteroidosPackages."android-init-hoki"}/etc/android-init/nonplat_property_contexts";
    "android-init/init.rc".source = "${asteroidosPackages."android-init-hoki"}/init.rc";
    "asteroid/machine.conf".source = "${asteroidosPackages."hoki-initramfs-machine"}/etc/asteroid/machine.conf";
  };

  # Matches meta-hoki initramfs-scripts-android bbappend behavior.
  mobile.boot.stage-1.contents = [
    {
      object = "${asteroidosPackages."hoki-initramfs-machine"}/init.machine";
      symlink = "/init.machine";
    }
  ];
  mobile.quirks.fb-refresher.stage-1.enable = lib.mkDefault true;

  # Upstream android-system-data_hoki-p installs vendor and system trees.
  systemd.tmpfiles.rules = lib.optionals includeAndroidSystemData [
    "L+ /system - - - - ${asteroidosPackages."android-system-data-hoki"}/system"
    "L+ /vendor - - - - ${asteroidosPackages."android-system-data-hoki"}/vendor"
  ];

  # Upstream ships external audio modules; enable when kernel module support is available.
  boot.extraModulePackages = lib.mkIf config.mobile.boot.stage-1.kernel.modular [ audioModules ];

  systemd.services.underclock = {
    description = "Underclock CPU/GPU to reduce hoki power usage";
    wantedBy = [ "basic.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 20";
      ExecStart = "${asteroidosPackages.hoki-underclock}/bin/underclock";
    };
  };
}
