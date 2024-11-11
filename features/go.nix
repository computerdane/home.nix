{ pkgs, ... }:

{
  home.packages = with pkgs; [
    buf-language-server
    go
    gopls
    protobuf
  ];
}
