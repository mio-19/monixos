{ pkgs, asteroidosPackages, ... }:
{
  environment.systemPackages = [
    asteroidosPackages.bluebinder
    asteroidosPackages."qt5-qpa-hwcomposer-plugin"
    asteroidosPackages."android-init-hoki"
    asteroidosPackages."udev-droid-system"
    asteroidosPackages."swclock-offset"
    pkgs.openssh
    pkgs.bluez
  ];

  services.udev.packages = [
    asteroidosPackages."udev-droid-system"
  ];

  # meta-hoki overrides BlueZ main.conf with an empty machine-specific file.
  environment.etc."bluetooth/main.conf".text = "";

  systemd.services.bluebinder = {
    description = "Simple proxy for Android binder Bluetooth through vhci";
    after = [ "android-system.service" ];
    before = [ "bluetooth.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "notify";
      EnvironmentFile = "-/var/lib/environment/bluebinder/*.conf";
      ExecStartPre = "${asteroidosPackages.bluebinder}/libexec/bluebinder/bluebinder_wait.sh";
      ExecStart = "${asteroidosPackages.bluebinder}/bin/bluebinder";
      ExecStartPost = "${asteroidosPackages.bluebinder}/libexec/bluebinder/bluebinder_post.sh";
      Restart = "always";
      TimeoutStartSec = "60";
    };
  };

  systemd.services.android-init = {
    description = "/system/bin/init compatibility service for vendor daemons";
    after = [ "local-fs.target" ];
    before = [ "basic.target" "network.target" "bluetooth.service" "ofono.service" "sensord.service" ];
    wantedBy = [ "graphical.target" ];
    conflicts = [ "shutdown.target" ];
    serviceConfig = {
      Type = "simple";
      DefaultDependencies = false;
      ExecStartPre = "${pkgs.coreutils}/bin/touch /dev/.coldboot_done";
      ExecStart = "/usr/libexec/hal-droid/system/bin/init";
    };
  };
}
