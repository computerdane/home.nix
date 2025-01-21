{ pkgs, lib, ... }:

let
  inherit (pkgs) stdenv;
in
lib.mkMerge [
  { programs.mpv.enable = true; }
  (lib.mkIf stdenv.isLinux {
    home.packages = with pkgs; [
      ghostty
      mumble
      prismlauncher
      signal-desktop
      vesktop
    ];

    programs.firefox.enable = true;
    programs.obs-studio.enable = true;
  })
]
