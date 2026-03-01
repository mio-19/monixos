{
  pkgs,
  ...
}:
let
  sources = import ../families/asteroidos/sources.nix {
    inherit (pkgs) fetchgit fetchFromGitHub;
  };
in
{
  imports = [
    ../families/asteroidos
    ../families/asteroidos/hoki.nix
  ];

  _module.args.asteroidosPackages = import ../families/asteroidos/packages.nix {
    inherit pkgs sources;
  };

  mobile.device.name = "hoki";
  mobile.device.identity = {
    # Fossil Gen 6 platform, AsteroidOS codename: hoki
    name = "Gen 6 (hoki)";
    manufacturer = "Fossil";
  };

  mobile.hardware = {
    soc = "qualcomm-sdm429w";
    ram = 1024;
    screen = {
      width = 416;
      height = 416;
    };
  };
  mobile.system.system = "aarch64-linux";

  mobile.boot.stage-1.kernel.package = pkgs.callPackage ./kernel {
    inherit sources;
  };

  mobile.system.type = "android";
  mobile.system.android = {
    device_name = "hoki";
    bootimg.flash = {
      offset_base = "0x80000000";
      offset_kernel = "0x00008000";
      offset_second = "0x00f00000";
      offset_ramdisk = "0x01000000";
      offset_tags = "0x00000100";
      pagesize = "4096";
    };
  };

  # Boot args adapted from AsteroidOS meta-hoki linux-hoki/img_info.
  boot.kernelParams = [
    "console=ttyMSM0,115200,n8"
    "androidboot.console=ttyMSM0"
    "androidboot.selinux=permissive"
    "androidboot.hardware=hoki"
    "user_debug=30"
    "msm_rtb.filter=0x237"
    "ehci-hcd.park=3"
    "androidboot.bootdevice=7824900.sdhci"
    "lpm_levels.sleep_disabled=1"
    "earlycon=msm_serial_dm,0x78b0000"
    "vmalloc=300M"
    "androidboot.usbconfigfs=true"
    "loop.max_part=7"
    "androidboot.memcg=true"
    "cgroup.memory=nokmem,nosocket"
    "buildvariant=user"
    "audit=0"
  ];

  mobile.usb.mode = "gadgetfs";
  # Temporary IDs until verified on-device.
  mobile.usb.idVendor = "18D1";
  mobile.usb.idProduct = "D001";
  mobile.usb.gadgetfs.functions = {
    rndis = "gsi.rndis";
    adb = "ffs.adb";
  };
}
