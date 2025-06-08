{
  inputs = {
    nixos-loongarch64-sd-image-builder.url = "github:FZDSLR/nixos-loongarch64-sd-image-builder";
    nixpkgs.follows = "nixos-loongarch64-sd-image-builder/nixpkgs";
    rust-overlay.follows = "nixos-loongarch64-sd-image-builder/rust-overlay";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://loongarch64-cross-test.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "loongarch64-cross-test.cachix.org-1:qiDlGssTkRx6m2MpYmUiA9DIWbsB2JyBiFUy47t67nQ="
    ];
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-loongarch64-sd-image-builder,
      ...
    }:
    {
      nixosConfigurations.loongarch64_99pi_tf_custom =
        nixos-loongarch64-sd-image-builder.nixosConfigurations.loongarch64_99pi_tf.extendModules
          {
            modules = [
              (
                { pkgs, ... }:
                {
                  system.stateVersion = "25.11";
                }
              )
              # or import a module from a file
              (./extra-config.nix)
            ];
          };
    };
}
