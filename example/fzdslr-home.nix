{ config, pkgs, ... }:

{
  home.username = "fzdslr";
  home.homeDirectory = "/home/fzdslr";

  home.packages = with pkgs; [
    quickjs-ng
  ];

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set fish_greeting
    '';
    shellAliases = {
      la = "eza --git --long --all --git --header";
    };
    plugins = [
      {
        name = "fzf-fish";
        src = pkgs.fishPlugins.fzf-fish;
      }
    ];
  };

  programs.eza = {
    enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.fastfetch = {
    enable = true;
    package = pkgs.fastfetchMinimal;
  };

  programs.vim = {
    enable = true;
    defaultEditor = true;
  };
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "25.11";
}
