{
  inputs = {
    nixos-loongarch64-builder.url = "github:FZDSLR/nixos-loongarch64-builder";
    nixpkgs.follows = "nixos-loongarch64-builder/nixpkgs";
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
      nixos-loongarch64-builder,
      ...
    }:
    let
      baseConfig = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit nixpkgs; };
        modules = [
          (import "${nixos-loongarch64-builder}/modules/cross-config.nix")
          (import ./modules/sd-image.nix)
          (import ./modules/config.nix)
        ];
      };

    in
    {
      nixosConfigurations = {
        loongarch64_99pi_tf = baseConfig;
      };
    };
}
