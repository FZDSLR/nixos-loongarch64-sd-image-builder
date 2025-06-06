{ lib, pkgs, nixpkgs, ... }:

{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_6_12_99pi_tf;
    initrd.includeDefaultModules = false;
    initrd.availableKernelModules = lib.mkForce [
      "ext4"
      "sd_mod"
      "mmc_block"
    ];
  };

  environment.systemPackages = with pkgs; [
    git
    curl
    vim
    neofetch
    htop
    which
    mtdutils
    i2c-tools
    openssl
    usbutils
    ntp
    jq
    file
    tree
    gnutar
    p7zip
    unzip
    busybox
    bat
  ];

  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PasswordAuthentication = lib.mkDefault true;
      PermitRootLogin = lib.mkDefault "prohibit-password";
    };
    openFirewall = lib.mkDefault true;
  };

  swapDevices = [ {
    device = "/var/lib/swapfile";
    size = 512;
  } ];

  networking.hostName = "nixos-loongarch64";

  users.users.root = {
    hashedPassword = lib.mkDefault "$y$j9T$QJlujDybThaC1.xVHXdny0$7LwbkchZr0GRAeswHkBSjhcC9YLmWnadJxEPVt4xgM4"; # root
  };
}
