{
  lib,
  config,
  pkgs,
  nixpkgs,
  ...
}:

{
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  hardware.enableAllHardware = lib.mkForce false; # https://github.com/NixOS/nixpkgs/issues/154163

  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_6_12_2k300;
    initrd.includeDefaultModules = false;
    initrd.availableKernelModules = lib.mkForce [
      "ext4"
      "sd_mod"
      "mmc_block"
    ];
    kernelParams = [
      "console=ttyS0,115200"
    ];
  };

  boot.loader = {
    grub.enable = false;
    generic-extlinux-compatible.enable = true;
  };

  fileSystems = lib.mkForce {
    "/boot" = {
      device = "/dev/disk/by-label/${config.sdImage.firmwarePartitionName}";
      fsType = "vfat";
      options = [ "nofail" ];
    };
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = [
        "noatime"
        "nodiratime"
      ];
    };
  };

  image.baseName = lib.mkDefault "nixos-loongarch64-sd-image";

  sdImage = {
    rootPartitionUUID = "d9d94464-db0a-4f2a-ab79-bfb15bc9c8b4";
    compressImage = false;
    populateFirmwareCommands = lib.optionalString (config.boot.loader.generic-extlinux-compatible.enable) ''
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./firmware
    '';
    firmwarePartitionName = "BOOT";
    firmwareSize = 256; # MiB

    populateRootCommands = ''
      mkdir -p ./files/boot
    '';
  };
}
