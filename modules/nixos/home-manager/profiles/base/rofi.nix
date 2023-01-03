{ config, inputs, lib, pkgs, ... }:
{

  home.packages = [
    (pkgs.rofi-pass.override {
      rofi = config.programs.rofi.finalPackage;
    })
  ];

  programs.rofi = {
    enable = true;
    font = "Iosevka Comfy 10";

    # This installs a copy of rofi without plugins but still using
    # global config, leading to "missing plugin" startup errors.
    # Work around by overriding rofi-pass to use rofi.finalPackage
    # pass.enable = true;

    plugins = [ pkgs.rofi-calc ];

    theme = config.scheme inputs.base16-rofi;

    extraConfig = {
      modi = lib.concatStringsSep "," [
        "window"
        "run"
        "ssh"
        "drun"
        "calc"
      ];
      terminal = "wezterm";
    };
  };
}