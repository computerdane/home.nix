{ pkgs, lib, ... }:

let
  inherit (pkgs) stdenv;
in
{
  home.packages = with pkgs; [
    dua
    ffmpeg-full
  ];

  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;
}
// lib.mkIf stdenv.isLinux {
  home.packages = with pkgs; [
    mumble
    prismlauncher
    signal-desktop
    vesktop
  ];

  programs.firefox.enable = true;
  programs.obs-studio.enable = true;
}
