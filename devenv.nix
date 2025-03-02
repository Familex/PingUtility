{
  pkgs,
  lib,
  ...
}: {
  languages = {
    # Needed for Android SDK
    java = {
      enable = true;
      jdk.package = lib.mkForce pkgs.jdk17;
    };
  };

  env = {
    JAVA_HOME = lib.mkForce pkgs.jdk17.home;
    ANDROID_JAVA_HOME = pkgs.jdk17.home;
  };

  android = {
    enable = true;
    flutter.enable = true;

    buildTools.version = ["33.0.1"];
    emulator.enable = false;

    android-studio = {
      enable = true;
      package = pkgs.android-studio;
    };

    extraLicenses = [
      "android-sdk-preview-license"
      "android-googletv-license"
      "android-sdk-arm-dbt-license"
      "google-gdk-license"
      "intel-android-extra-license"
      "intel-android-sysimage-license"
      "mips-android-sysimage-license"
    ];
  };

  scripts = {
    run-android-studio.exec = ''
      1> /dev/null 2> /dev/null android-studio "$DEVENV_ROOT" & disown
    '';

    adb-restart.exec = ''
      adb kill-server
      adb start-server
    '';
  };
}
