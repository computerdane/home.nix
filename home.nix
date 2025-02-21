{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  pkgs-1os,
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
    ++ (with pkgs-1os; [ mc-quick ])
    ++ (with pkgs-unstable; [ nixd ])
    ++ (
      with pkgs;
      [
        aria2
        curl
        dua
        ffmpeg-full
        gitui
        jq
        netcat
        nil
        nixfmt-rfc-style
        nmap
        pv
        ranger
        ripgrep
        shell-gpt
        tldr
        tree
        unzip
        wget
        wireguard-tools
        zip
      ]
      ++ (with fishPlugins; [
        colored-man-pages
        puffer
        tide
      ])
    )
    ++ (if stdenv.isLinux then with pkgs; [ ghostty ] else [ ]);

  programs.bat.enable = true;
  programs.fd.enable = true;
  programs.fzf.enable = true;
  programs.yt-dlp.enable = true;
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
    icons = "auto";
  };

  programs.fish = {
    enable = true;
    shellInit = lib.mkMerge [
      ''
        set fish_greeting
      ''
      (lib.mkIf stdenv.isLinux (
        lib.concatStringsSep "\n" (
          lib.map
            (cmd: ''
              complete -w journalctl ${cmd}
              complete -w "systemctl status" ${cmd}
            '')
            [
              "logs"
              "flogs"
            ]
        )
      ))
    ];
    shellAliases = lib.mkMerge [
      {
        bop = "nix run github:computerdane/bop-bun --";
        cat = "bat";
        gpt = "OPENAI_API_KEY=$(cat ~/.openai-api-key) sgpt";
        my-tide-configure = "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Light --prompt_spacing=Sparse --icons='Few icons' --transient=No";
        rivals-kill-switch = "pkill -9 Xwayland && XAUTHORITY=/run/user/1000/xauth* DISPLAY=:0 steam steam://rungameid/2767030";
      }
      (lib.mkIf stdenv.isLinux {
        logs = "journalctl --no-hostname -aeu";
        flogs = "journalctl --no-hostname -afu";
      })
    ];
  };

  programs.git = {
    enable = true;
    userName = "Dane Rieber";
    userEmail = "danerieber@gmail.com";
    extraConfig.init.defaultBranch = "main";
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
        rulers = [ 80 ];
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

  home.file.".config/ghostty/config".text = ''
    theme = Dracula
    background-opacity = 0.9
    maximize = true
  '';

  # Taken from https://github.com/nix-community/home-manager/issues/3090#issuecomment-2010891733
  # Creates a file with specific permissions
  home.file.".config/shell_gpt/.sgptrc_init" = {
    text = ''
      DEFAULT_MODEL=gpt-4o
    '';
    onChange = ''
      rm -f ${config.home.homeDirectory}/.config/shell_gpt/.sgptrc
      cp ${config.home.homeDirectory}/.config/shell_gpt/.sgptrc_init ${config.home.homeDirectory}/.config/shell_gpt/.sgptrc
      chmod a+rw ${config.home.homeDirectory}/.config/shell_gpt/.sgptrc
    '';
  };

  # Use fish shell on systems with bash or zsh
  home.file.".profile".text = "fish";
  home.file.".zshrc".text = "fish";

  home.username = "dane";
  home.homeDirectory = if stdenv.isDarwin then "/Users/dane" else "/home/dane";

  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
