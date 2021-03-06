{ config, pkgs, ... }:

let sources = import ../../nix/sources.nix;
in
{
  imports = [
    <home-manager/nixos>
    ../../modules/common/nixos
    ../../modules/nixos/nixos
    "${sources.nixos-hardware}/lenovo/thinkpad/x1/7th-gen"
  ];

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  console = {
    font = "ter-v32n";
    keyMap = "us";
    packages = [ pkgs.terminus_font ];
  };

  fonts.fontconfig.dpi = 210;

  hardware.acpilight.enable = true;

  hardware.pulseaudio = {
    enable = true;
    package = pkgs.pulseaudioFull;
  };

  hardware.video.hidpi.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    users.matt = {
      imports = [ ./home.nix ];
      profiles.personal.enable = true;
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking = {
    hostName = "karakuri";
    wireless.enable = true;
    useDHCP = false;
    interfaces.wlp0s20f3.useDHCP = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = import ../../overlays;
  };

  programs.fish.enable = true;

  programs.mtr.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  services.geoclue2 = {
    enable = true;
    enableWifi = true;
  };

  services.printing.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.xterm.enable = true;
    displayManager.lightdm.greeters.gtk.extraConfig = "xft-dpi=320";
    dpi = 320;
    layout = "us";
    libinput = {
      enable = true;
      touchpad = {
        disableWhileTyping = true;
        naturalScrolling = true;
      };
    };
  };

  sound = {
    enable = true;
    mediaKeys.enable = true;
  };

  system.stateVersion = "20.09";

  time.timeZone = "America/Los_Angeles";

  users.users.matt = {
    isNormalUser = true;
    extraGroups = [ "video" "wheel" ];
    shell = pkgs.fish;
  };
}
