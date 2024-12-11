{ pkgs, ... }:

{
  home.packages = with pkgs; [
    buf
    go
    gopls
    protobuf
  ];
}
