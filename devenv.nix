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
    platforms.version = lib.mkDefault [
      "31" # for dynamic_color
      "34" # for something else
    ];

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

    # not tested
    fix-gradle.exec = ''
      tmp_proj_root=$(mktemp --directory)
      cd "$tmp_proj_root"
      flutter create --platforms=android --project-name ping_utility .
      rm -r ./lib ./.gitignore ./test
      cp -r "$DEVENV_ROOT/src/lib" ./lib
      cp -r "$DEVENV_ROOT/src/test" ./test
      flutter pub add \
        provider dart_ping \
        fl_chart dynamic_color fuzzy \
        holding_gesture sqflite

      flutter build apk --release -v || exit 1

      cp "$DEVENV_ROOT"
      cp "$DEVENV_ROOT/src/.gitignore" "$tmp_proj_root"
      rm -r "$DEVENV_ROOT/src"
      mv "$tmp_proj_root" "$DEVENV_ROOT/src"
    '';
  };
}
