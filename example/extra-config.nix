{
  lib,
  pkgs,
  nixpkgs,
  ...
}:
{
  users.users."fzdslr" = {
    hashedPassword = "$y$j9T$NZY7.GJLZWNyMlxD/XWQq/$ireCUMLao7t/mT/jrInr.ADGR8eVzUnHYhKw81qIYT8";

    isNormalUser = true;
    home = "/home/fzdslr";
    extraGroups = [
      "users"
      "networkmanager"
      "wheel"
      "docker"
      "spi"
      "i2c"
      "gpio"
      "media"
    ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYA3PS2P9GDKxQ/0XavUaCgHRDpvFQwnmytCQAHkX53 fzdslr_nixos_z3air"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHU/bF4HG69uDm/JkNYUJi8RdmHK0N7YanuLgK8GaMFd fzdslr@qq.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALKfA+7TiISP4WoSVU4QORt9VmAJFcBpSglRrMQCxc+ fzdslr-win-to-go"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJlnkfwUEBt+Ws6p8OEE1rqv25IUhk6T1AaQVqXyLHT fzdslr@qq.com"
    ];
  };

  users.users.root = {
    hashedPassword = "$y$j9T$W66K1V8tXxYsCfTTXrQeT1$sSayRSX/4hnjuI2XKI5M1dczYy8uM/gy/F0CVSbDSe";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYA3PS2P9GDKxQ/0XavUaCgHRDpvFQwnmytCQAHkX53 fzdslr_nixos_z3air"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHU/bF4HG69uDm/JkNYUJi8RdmHK0N7YanuLgK8GaMFd fzdslr@qq.com"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIALKfA+7TiISP4WoSVU4QORt9VmAJFcBpSglRrMQCxc+ fzdslr-win-to-go"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBJlnkfwUEBt+Ws6p8OEE1rqv25IUhk6T1AaQVqXyLHT fzdslr@qq.com"
    ];
  };

  users.groups.media = { };

  nix.settings = {
    substituters = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://loongarch64-cross-test.cachix.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "loongarch64-cross-test.cachix.org-1:qiDlGssTkRx6m2MpYmUiA9DIWbsB2JyBiFUy47t67nQ="
    ];
  };

  imports = [ ./alist.nix ];

  boot.kernelPackages = pkgs.linuxPackages_6_12_2k300_rt;

  time.timeZone = "Asia/Shanghai";

  nixpkgs.config.allowUnfree = true;

  users.groups.gpio = { };
  users.groups.spi = { };
  services.udev.extraRules = ''
    SUBSYSTEM=="gpio", KERNEL=="gpiochip*", ACTION=="add", RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys/class/gpio/export /sys/class/gpio/unexport ; chmod 220 /sys/class/gpio/export /sys/class/gpio/unexport'"
    SUBSYSTEM=="gpio", KERNEL=="gpio*", ACTION=="add",RUN+="${pkgs.bash}/bin/bash -c 'chown root:gpio /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value ; chmod 660 /sys%p/active_low /sys%p/direction /sys%p/edge /sys%p/value'"
    SUBSYSTEM=="spidev", KERNEL=="spidev1.0", GROUP="spi", MODE="0660"
  '';

  services.openssh = {
    enable = true;
    settings = {
      X11Forwarding = false;
      PasswordAuthentication = true;
      PermitRootLogin = "prohibit-password";
    };
    openFirewall = true;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };

  programs.fish.enable = true;

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true;
      package = pkgs.podman;
    };
  };

  services.ntp = {
    enable = true;
    servers = [
      "ntp.aliyun.com"
      "ntp.tencent.com"
    ];
  };

  services.alist = {
    enable = true;
    package = pkgs.openlist;
    group = "media";
    settings = {
      scheme = {
        address = "0.0.0.0";
        http_port = 5244;
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."default" = {
      default = true;
      listen = [
        {
          addr = "0.0.0.0";
          port = 80;
        }
      ];
      root = "/var/www/default";
      locations."/" = {
        index = "index.html index.htm";
      };
    };
  };

  systemd.services.update-system = {
    description = "Auto update NixOS system";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart =
        let
          update-system = pkgs.writeShellApplication {
            name = "update-system";
            text = (builtins.readFile ./update-system.sh);
            runtimeInputs = with pkgs; [ nix curl ];
          };
        in
        lib.getExe update-system;
      User = "root";
      Group = "root";
      Restart = "no";
    };
  };

  systemd.timers.update-system = {
    description = "Timer for daily system update at 8:00 AM";
    timerConfig = {
      OnCalendar = "*-*-* 08:00:00";
      Unit = "update-system.service";
    };
    wantedBy = [ "timers.target" ];
  };

  networking.firewall.allowedTCPPorts = [
    80
    5244
  ];
}
