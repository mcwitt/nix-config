{ lib, pkgs, ... }: {
  programs.alacritty = {
    enable = true;

    settings = {
      colors = {
        # Colors (Solarized Dark)
        # Default colors
        primary = {
          background = "#002b36"; # base03
          foreground = "#839496"; # base0
        };

        # Cursor colors
        cursor = {
          text = "#002b36"; # base03
          cursor = "#839496"; # base0
        };

        # Normal colors
        normal = {
          black = "#073642"; # base02
          red = "#dc322f"; # red
          green = "#859900"; # green
          yellow = "#b58900"; # yellow
          blue = "#268bd2"; # blue
          magenta = "#d33682"; # magenta
          cyan = "#2aa198"; # cyan
          white = "#eee8d5"; # base2
        };

        # Bright colors
        bright = {
          black = "#002b36"; # base03
          red = "#cb4b16"; # orange
          green = "#586e75"; # base01
          yellow = "#657b83"; # base00
          blue = "#839496"; # base0
          magenta = "#6c71c4"; # violet
          cyan = "#93a1a1"; # base1
          white = "#fdf6e3"; # base3
        };
      };

      font = {
        normal.family = "Iosevka Nerd Font";
        size = lib.mkDefault 10;
      };

      window.padding = {
        x = 5;
        y = 5;
      };
    };
  };

  # work around "unknown terminal type" issue with ssh
  programs.fish.shellAliases.ssh =
    "TERM=xterm-256color ${pkgs.openssh}/bin/ssh";
  programs.zsh.shellAliases.ssh =
    "TERM=xterm-256color ${pkgs.openssh}/bin/ssh";
}
