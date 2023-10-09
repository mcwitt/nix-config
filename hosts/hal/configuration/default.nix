{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = [ "xhci_pci" "usbhid" "usb_storage" ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  i18n.defaultLocale = "en_US.UTF-8";

  networking.hostName = "hal";

  nix = {
    gc.automatic = true;
    gc.dates = "weekly";
    settings.trusted-public-keys = [ "golem:eibXP6qvkaDB9Jvh/MkR4D/dVL7HYDBJI2srJZgVhGE=" ];
  };

  profiles.home-automation.enable = true;

  time.timeZone = "America/Los_Angeles";

  services.xserver.layout = "us";

  users.users.matt = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.systemPackages = with pkgs; [
    home-assistant-cli
    vim
  ];

  services.avahi = {
    enable = true;
    nssmdns = true;
    publish = {
      enable = true;
      addresses = true;
    };
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  services.zigbee2mqtt.settings.serial.port = "/dev/serial/by-id/usb-ITEAD_SONOFF_Zigbee_3.0_USB_Dongle_Plus_V2_20230602161357-if00";

  system.stateVersion = "23.11";

  hardware.enableRedistributableFirmware = true;
}
