{ config, lib, pkgs, ... }:
{
  services.polybar = {
    enable = true;

    package = pkgs.polybar.override {
      alsaSupport = true;
      githubSupport = true;
    };

    script = ''
      polybar &
    '';

    settings =
      let
        windowMargin = 8;
        colors = config.scheme.withHashtag;
      in
      with config.scheme.withHashtag; {
        "colors" = {
          background = colors.base01;
          background-alt = colors.base02;
          foreground = colors.base05;
          primary = colors.base0D;
          secondary = colors.base0A;
          alert = colors.base08;
          disabled = colors.base03;
        };

        "bar/main" = rec {
          offset-x = 2 * windowMargin;
          width = "100%:-${toString (2 * offset-x)}";
          height = "20pt";
          radius = 6;

          dpi = 0; # automatically choose dpi

          background = ''''${colors.background}'';
          foreground = ''''${colors.foreground}'';

          line-size = 5;

          border-size = 5;
          border-color = colors.base00;

          padding-left = 0;
          padding-right = 1;

          module-margin = 1;

          separator = "|";
          separator-foreground = ''''${colors.disabled}'';

          font = [ "Iosevka Comfy:size=10;4" ];

          modules-left = lib.concatStringsSep " " [ "xworkspaces" "xwindow" ];
          modules-right = lib.concatStringsSep " " [ "filesystem" "pulseaudio" "xkeyboard" "memory" "cpu" "wlan" "eth" "date" ];

          cursor-click = "pointer";
          cursor-scroll = "ns-resize";

          enable-ipc = true;

          tray-position = "right";
          tray-maxsize = 32;

          wm-restack = "generic";

          override-redirect = true;
        };

        "global/wm" = {
          margin-bottom = windowMargin;
        };

        "module/xworkspaces" = {
          type = "internal/xworkspaces";

          label-active = "%name%";
          label-active-background = ''''${colors.background-alt}'';
          label-active-underline = ''''${colors.primary}'';
          label-active-padding = 1;

          label-occupied = "%name%";
          label-occupied-padding = 1;

          label-urgent = "%name%";
          label-urgent-background = ''''${colors.alert}'';
          label-urgent-padding = 1;

          label-empty = "%name%";
          label-empty-foreground = ''''${colors.disabled}'';
          label-empty-padding = 1;
        };

        "module/xwindow" = {
          type = "internal/xwindow";
          label = "%title:0:60:...%";
        };

        "module/filesystem" = {
          type = "internal/fs";
          interval = 25;

          mount = [ "/" ];

          label-mounted = "%{F${colors.base0D}}%mountpoint%%{F-} %percentage_used%%";

          label-unmounted = "%mountpoint% not mounted";
          label-unmounted-foreground = ''''${colors.disabled}'';
        };

        "module/pulseaudio" = {
          type = "internal/pulseaudio";

          format-volume-prefix = "VOL ";
          format-volume-prefix-foreground = ''''${colors.primary}'';
          format-volume = "<label-volume>";

          label-volume = "%percentage%%";

          label-muted = "muted";
          label-muted-foreground = ''''${colors.disabled}'';

        };

        "module/memory" = {
          type = "internal/memory";
          interval = 2;
          format-prefix = "RAM ";
          format-prefix-foreground = ''''${colors.primary}'';
          label = "%percentage_used:2%%";
        };

        "module/cpu" = {
          type = "internal/cpu";
          interval = 2;
          format-prefix = "CPU ";
          format-prefix-foreground = ''''${colors.primary}'';
          label = "%percentage-sum:3%%";
        };

        "network-base" = {
          type = "internal/network";
          interval = 5;
          format-connected = "<label-connected>";
          format-disconnected = "<label-disconnected>";
          label-disconnected = "%{F${colors.base0D}}%ifname%%{F${colors.base03}} disconnected";
        };

        "module/eth" = {
          "inherit" = "network-base";
          interface-type = "wired";
          label-connected = "%{F${colors.base0D}}%ifname%%{F-} %upspeed:7% %downspeed:7%";
          speed-unit = "";
        };

        "module/date" = {
          type = "internal/date";
          interval = 1;

          date = "%Y-%m-%d %a %H:%M:%S";

          label = "%date%";
          label-foreground = ''''${colors.primary}'';
        };

        "settings" = {
          screenchange-reload = true;
          pseudo-transparency = true;
        };
      };
  };
}