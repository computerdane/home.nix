{ pkgs, lib, ... }:

let
  inherit (pkgs) stdenv;
  bop = pkgs.writeShellScriptBin "bop" ''
    ssh nf6.sh "fd -p -t f '$*' /nas/hl/music" | awk '{print "sftp://nf6.sh" $0}' | xargs -d '\n' -n 1000 mpv --volume=50
  '';
in
lib.mkMerge [
  {
    home.packages = with pkgs; [
      bop
      ffmpeg-full
    ];

    programs.mpv.enable = true;
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
