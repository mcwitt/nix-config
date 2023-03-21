{ config, inputs, lib, pkgs, ... }:

let cfg = config.profiles.desktop;
in
{
  options.profiles.desktop.enable = lib.mkEnableOption "Profile for machines with graphical desktops";

  imports = [
    ./polybar.nix
    ./rofi.nix
    ./xmonad.nix
  ];

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [ xfce.thunar ];

    home.pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ";
      size = lib.mkDefault 48;
      x11.enable = true;
    };

    programs.rofi.enable = true;

    services.dunst = {
      enable = true;
      settings = with config.scheme.withHashtag; {
        global = {
          browser = "${config.programs.chromium.package}/bin/chromium-browser";
          markup = "full";
          max_icon_size = 100;
          text_icon_padding = 10;
        };
      };
    };

    services.flameshot = {
      enable = true;
      settings.General.showStartupLaunchMessage = false;
    };

    services.gammastep = {
      enable = true;
      tray = true;
      provider = "geoclue2";
      settings.general = {
        adjustment-method = "randr";
        brightness-night = 0.6;
      };
    };

    services.gpg-agent = {
      pinentryFlavor = null;
      extraConfig =
        let
          pinentry-rofi-with-env = pkgs.writeShellApplication {
            name = "pinentry-rofi-with-env";
            runtimeInputs = with pkgs; [ coreutils rofi ];
            text = ''
              "${pkgs.pinentry-rofi}/bin/pinentry-rofi" "$@"
            '';
          };
        in
        ''
          pinentry-program ${pinentry-rofi-with-env}/bin/pinentry-rofi-with-env
        '';
    };

    services.picom = {
      enable = true;
      backend = "glx";
      activeOpacity = 1.0;
      inactiveOpacity = 0.9;
      fade = true;
      fadeDelta = 3;
      settings = {
        corner-radius = 6;
        rounded-corners-exclude = [ "class_g = 'Rofi'" ];
      };
    };

    services.polybar.enable = true;

    services.udiskie = {
      enable = true;
      tray = "always";
    };

    xdg = {
      enable = true;
      mimeApps = {
        enable = true;
        defaultApplications =
          let
            mkDefaults = apps: types: builtins.listToAttrs
              (map (type: lib.nameValuePair type apps) types);
          in
          mkDefaults [ "feh.desktop" ] [
            "image/bmp"
            "image/gif"
            "image/jpeg"
            "image/jpg"
            "image/png"
            "image/webp"
          ] //
          mkDefaults [ "chromium-browser.desktop" ] [
            "text/html"
            "x-scheme-handler/http"
            "x-scheme-handler/https"
            "x-scheme-handler/ftp"
          ] // {
            "application/pdf" = [ "org.pwmt.zathura.desktop" ];
            "text/plain" = [ "emacsclient.desktop" ];
          };
      };
    };

    xsession.enable = true;
    xsession.windowManager.xmonad.enable = true;
  };
}
