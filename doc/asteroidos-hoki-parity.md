# AsteroidOS Hoki Parity Tracker

This tracks convergence between this tree and upstream AsteroidOS `meta-hoki`.

Reference sources used:

- `/tmp/asteroidos-audit/meta-smartwatch/meta-hoki`
- `/tmp/asteroidos-audit/meta-asteroid`
- https://wiki.asteroidos.org/index.php/Porting_Guide

## Machine-level packages (`meta-hoki/conf/machine/hoki.conf`)

- [x] `udev-droid-system`
- [x] `bluebinder`
- [x] `swclock-offset`
- [x] `underclock`
- [x] `asteroid-hrm`
- [x] `asteroid-compass`
- [x] `qrtr` (optional, enabled when available in package set)
- [x] `sensorfw-hybris-binder-plugins`
- [x] `android-system-data` (implemented as `android-system-data-hoki`, enabled when unfree is allowed)
- [x] `linux-audio-modules-hoki` (packaged; enabled when kernel module mode is enabled)

## `meta-hoki` bbappend equivalents

- [x] `android-init`: `init.rc`, `plat_property_contexts`, `nonplat_property_contexts`
- [x] `libncicore`: `libncicore.conf`
- [x] `ngfd`: `51-ffmemless.ini`
- [x] initramfs machine hook: `init.machine.sh` + `machine.conf`
- [x] stage-1 fb refresher behavior aligned (`mobile.quirks.fb-refresher.stage-1.enable`)
- [x] `lipstick` hwcomposer relationship approximated (`qt5-qpa-hwcomposer-plugin` in family boot stack)
- [x] `nfcd`: binder plugin dependency
- [x] `geoclue`: binder provider dependency
- [x] `pulseaudio`: `hoki`-specific override semantics matched (upstream removes `pulseaudio-modules-droid` from `pulseaudio-server` RDEPENDS for this device)
- [x] `bluez` machine-specific override semantics (`/etc/bluetooth/main.conf` now forced to upstream-empty content)

## Service behavior alignment

- [x] `bluebinder` ordering/target moved toward upstream (`After=android-system.service`, `WantedBy=multi-user.target`)
- [x] `android-init` ordering/default-dependency behavior aligned closer to upstream unit

## Remaining high-impact work

1. Validate runtime behavior for geoclue/sensorfw binder integration on-device.
2. Enable and validate `linux-audio-modules-hoki` runtime with a modular kernel path.
3. Revisit qml stack hacks to reduce divergence from AsteroidOS recipe expectations.
