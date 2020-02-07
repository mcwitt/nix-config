{ config, pkgs, ... }:

{
  imports = [ ../modules/fonts.nix ../modules/packages.nix ];

  environment = {
    darwinConfig = "$HOME/.config/nixpkgs/darwin-configuration.nix";
    shells = with pkgs; [ bashInteractive zsh ];
  };

  nix = {
    maxJobs = 8;
    buildCores = 0;

    # Auto upgrade nix package and the daemon service.
    # services.nix-daemon.enable = true;
    # package = pkgs.nix;
  };

  programs = {
    gnupg = {
      enable = true;
      agent.enable = true;
    };

    tmux = {
      enable = true;
      enableSensible = true;
      enableVim = true;
    };

    zsh.enable = true;
  };

  services = {
    emacs.enable = true;
    postgresql.enable = true;
  };

  system = {
    # Used for backwards compatibility, please read the changelog before changing.
    # $ darwin-rebuild changelog
    stateVersion = 4;

    defaults.dock = {
      autohide = true;
      launchanim = false;
      orientation = "left";
    };
  };
}