{
  pkgs,
  pkgs-nf6,
  pkgs-unstable,
  ...
}:

let
  inherit (pkgs) stdenv;
  hm-update-pull = pkgs.writeShellScriptBin "hm-update-pull" ''
    cd ~/.config/home-manager && \
      git pull && \
      home-manager switch
  '';
  hm-update-push = pkgs.writeShellScriptBin "hm-update-push" ''
    cd ~/.config/home-manager && \
      git pull && \
      nix flake update && \
      home-manager switch && \
      git add . && \
      git commit -m "[hmup-update-push] $(date -I)" && \
      git push
  '';
in
{
  home.packages =
    [
      hm-update-pull
      hm-update-push
    ]
    ++ (with pkgs-nf6; [ client-cli ])
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
        tldr
        tree
        wget
        wireguard-tools
      ]
      ++ (with fishPlugins; [
        colored-man-pages
        puffer
        tide
      ])
    );

  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;

  programs.btop = {
    enable = true;
    settings = {
      color_theme = "Dracula";
      theme_background = false;
      update_ms = 100;
    };
  };

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
    matchBlocks."knightf6.com".port = 105;
  };

  # Use fish shell on systems with bash or zsh
  home.file.".profile".text = "fish";
  home.file.".zshrc".text = "fish";

  home.username = "dane";
  home.homeDirectory = if stdenv.isDarwin then "/Users/dane" else "/home/dane";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
