{ lib, config, pkgs, nixpkgs, ... }:

{
  imports = [
    "${nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
  ];

  hardware.enableAllHardware = lib.mkForce false; # https://github.com/NixOS/nixpkgs/issues/154163

  boot.kernelParams = [
    "console=ttyS0,115200"
    "root=/dev/disk/by-label/NIXOS_SD"
    "rootfstype=ext4"
    "rootwait"
    "rw"
    "noatime"
  ];

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

  sdImage = {
    rootPartitionUUID = "d9d94464-db0a-4f2a-ab79-bfb15bc9c8b4";
    imageBaseName = lib.mkDefault "nixos-loongarch64-sd-image";
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
