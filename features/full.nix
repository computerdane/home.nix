{ pkgs, ... }:

{
  home.packages = with pkgs; [
    dua
    ffmpeg-full
  ];

  programs.mpv.enable = true;
  programs.yt-dlp.enable = true;
}
