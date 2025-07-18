{
  lib,
  pkgs,
  nixpkgs,
  ...
}:

{
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

  swapDevices = lib.mkDefault [
    {
      device = "/var/lib/swapfile";
      size = 512;
    }
  ];

  networking.hostName = lib.mkDefault "nixos-loongarch64";

  users.users.root = {
    hashedPassword = lib.mkDefault "$y$j9T$QJlujDybThaC1.xVHXdny0$7LwbkchZr0GRAeswHkBSjhcC9YLmWnadJxEPVt4xgM4"; # root
  };
}
