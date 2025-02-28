{pkgs, ...}: {
  android = {
    enable = true;
    flutter.enable = true;

    buildTools.version = ["33.0.1"];
    emulator.enable = false;

    android-studio = {
      enable = true;
      package = pkgs.android-studio;
    };
  };

  scripts.run-android-studio.exec = ''
    1> /dev/null 2> /dev/null android-studio & disown
  '';
}
