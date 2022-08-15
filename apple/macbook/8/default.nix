{ lib, pkgs, modulesPath, ... }:

{
  imports = [
    ../.
    "${modulesPath}/hardware/network/broadcom-43xx.nix"
  ];

  boot = {
    initrd.kernelModules = [ "spi_pxa2xx_platform" "spi_pxa2xx_pci" "applespi" ];
    # Divides power consumption by two.
    kernelParams = [ "acpi_osi=" "irqpoll" ];
  };

  services.mbpfan.enable = false;

  powerManagement = {
    # Enable gradually increasing/decreasing CPU frequency, rather than using
    # "powersave", which would keep CPU frequency at 0.8GHz.
    cpuFreqGovernor = lib.mkDefault "conservative";

    # brcmfmac being loaded during hibernation would not let a successful resume
    # https://bugzilla.kernel.org/show_bug.cgi?id=101681#c116.
    # Also brcmfmac could randomly crash on resume from sleep.
    powerUpCommands = lib.mkBefore "${pkgs.kmod}/bin/modprobe brcmfmac";
    powerDownCommands = lib.mkBefore "${pkgs.kmod}/bin/rmmod brcmfmac";
  };

}
