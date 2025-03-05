{
  config,
  pkgs,
  lib,
  ...
}: {
  languages = {
    # Needed for Android SDK
    java = {
      enable = lib.mkDefault true;
      jdk.package = (lib.mkOverride 999) pkgs.jdk17;
    };
  };

  env = {
    JAVA_HOME = (lib.mkOverride 999) pkgs.jdk17.home;
    ANDROID_JAVA_HOME = lib.mkDefault pkgs.jdk17.home;
  };

  android = {
    enable = lib.mkDefault true;
    flutter.enable = lib.mkDefault true;

    buildTools.version = lib.mkDefault ["33.0.1"];

    android-studio = {
      enable = lib.mkDefault true;
    };
  };

  scripts = {
    run-android-studio = lib.mkIf config.android.android-studio.enable {
      exec = ''
        1> /dev/null 2> /dev/null android-studio "$DEVENV_ROOT" & disown
      '';
    };

    adb-restart.exec = ''
      adb kill-server
      adb start-server
    '';
  };
}
