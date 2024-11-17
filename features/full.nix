{ pkgs, lib, ... }:

let
  inherit (pkgs) stdenv;
in
lib.mkMerge [
  {
    home.packages = with pkgs; [ ffmpeg-full ];

    programs.mpv = {
      enable = true;
      config.volume = 50;
    };
    programs.yt-dlp.enable = true;
  }
  (lib.mkIf stdenv.isLinux {
    home.packages = with pkgs; [
      mumble
      prismlauncher
      signal-desktop
      vesktop
    ];

    programs.firefox.enable = true;
    programs.obs-studio.enable = true;
  })
]
