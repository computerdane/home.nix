{ pkgs, pkgs-unstable, ... }:

let
  inherit (pkgs) stdenv;
  hup = pkgs.writeShellScriptBin "hup" ''
    cd ~/.config/home-manager && \
      git pull && \
      home-manager switch
  '';
in
{
  home.packages =
    [ hup ]
    ++ (with pkgs-unstable; [ nixd ])
    ++ (
      with pkgs;
      [
        curl
        dua
        netcat
        nil
        nixfmt-rfc-style
        nmap
        pv
        tree
        wget
      ]
      ++ (with fishPlugins; [
        colored-man-pages
        puffer
        tide
      ])
    );

  programs.bat.enable = true;
  programs.btop.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    git = true;
    icons = true;
  };

  programs.fish = {
    enable = true;
    shellInit = ''
      set fish_greeting
    '';
    shellAliases = {
      cat = "bat";
      my-tide-configure = "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Light --prompt_spacing=Sparse --icons='Few icons' --transient=No";
    };
  };

  programs.git = {
    enable = true;
    userName = "Dane Rieber";
    userEmail = "danerieber@gmail.com";
  };

  programs.helix = {
    enable = true;
    package = pkgs-unstable.helix;
    defaultEditor = true;
    themes = {
      dracula_nobg = {
        inherits = "dracula";
        "ui.background" = "{}";
      };
    };
    settings = {
      theme = "dracula_nobg";
      editor = {
        line-number = "relative";
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
        indent-guides.render = true;
        bufferline = "always";
        soft-wrap.enable = true;
        true-color = true;
      };
    };
    languages.language-server.nixd.command = "nixd";
    languages.language = [
      {
        name = "nix";
        formatter.command = "nixfmt";
        auto-format = true;
        language-servers = [
          "nixd"
          {
            name = "nil";
            except-features = [ "completion" ];
          }
        ];
      }
    ];
  };

  programs.ssh = {
    enable = true;
    matchBlocks."nf6.sh".port = 105;
  };

  # Use fish shell on systems with bash or zsh
  home.file.".profile".text = "fish";
  home.file.".zshrc".text = "fish";

  home.username = "dane";
  home.homeDirectory = if stdenv.isDarwin then "/Users/dane" else "/home/dane";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
