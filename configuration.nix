{
  config,
  pkgs,
  lib,
  ...
}: {
  config.system.stateVersion = "24.11"; # Before changing this value read the documentation for this option
  options. userDefinedGlobalVariables = {
    username = lib.mkOption {
      default = "nixos"; # Changing the username breaks stuff
      type = lib.types.str;
    };
  };
  config.services.displayManager.autoLogin.enable = true;
  config.services.displayManager.autoLogin.user = config.userDefinedGlobalVariables.username;
  config.users.users.${config.userDefinedGlobalVariables.username} = {
    isNormalUser = true; # To set a password: ‘passwd'
    extraGroups = ["networkmanager" "wheel" "input" "uinput" "docker" "video" "dialout" "plugdev" "adbusers" "audio"];
  };

  config.environment.variables = {
    EDITOR = "hx";
    BROWSER = "firefox";
    TERMINAL = "foot";
    SHELL = "fish";
    XDG_CURRENT_DESKTOP = "river";
    XDG_SESSION_TYPE = "wayland";
    WAYLAND_DISPLAY = "wayland-1";
    MOZ_ENABLE_WAYLAND = "1";
    GTK_USE_PORTAL = "1";
    NIXOS_XDG_OPEN_USE_PORTAL = "1";
    NIXOS_OZONE_WL = "1";
    # Python
    PYTHONDONTWRITEBYTECODE = 1;
    # Go
    GOROOT = "${pkgs.go}/share/go";
    GOPATH = "$HOME/go";
    PATH = [
      "$HOME/go//bin"
      "${pkgs.go}/share/go"
    ];
    # Claude-code
    CLAUDE_CODE_USE_BEDROCK = 1;
    AWS_REGION = "us-east-1";
    ANTHROPIC_MODEL = "us.anthropic.claude-3-7-sonnet-20250219-v1:0";
  };
  ## PROGRAM CONFIGURATION
  # Most programs I configure through regular dotfiles using GNU Stow, without reliance on nix.
  # See dotfiles/** and scripts/stow_restow.sh
  imports = [
    # For some programs I use nix options:
    ./dotfiles/river.nix
    ./dotfiles/fcitx5.nix
    ./dotfiles/kanata.nix
    ./dotfiles/restic.nix
    ./dotfiles/fish.nix
    ./dotfiles/tmux.nix
    ./dotfiles/gdm.nix
    ./dotfiles/steam.nix
    ./secrets/sopsnix.nix
  ];

  ## PROGRAM INSTALLATION
  config.environment.systemPackages = with pkgs; [
    # Backups
    restic
    # Api key management
    sops # + sops-nix downloaded through flakes
    age
    ripsecrets
    # Password manager
    keepassxc
    # Dotfiles symlinking
    stow
    # Keyboard remapper
    kanata-with-cmd
    # Displays
    wlr-randr
    wl-mirror
    # Compositor
    river
    wayland
    wl-clipboard
    i3bar-river
    i3status-rust
    mako
    # Terminal multiplexer
    tmux
    sesh
    # IDE
    helix
    lazygit
    serpl
    # AI assistant
    claude-code
    aichat
    ## aider-chat as nix-shell
    playwright # for aider-chat
    # Aws
    awscli2
    # App launcher
    fuzzel
    # Terminal
    foot
    ghostty
    # Interactive shell
    fish
    # Login shell (scripts)
    bash
    gum
    zoxide
    ripgrep
    fzf
    fd
    # File manager
    yazi
    bashmount
    # File manager gui
    nautilus
    # Browser
    (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {})
    brave
    # RSS
    newsboat
    # Pdfs
    sioyek
    # Western fonts
    hack-font
    # Asian fonts
    noto-fonts
    noto-fonts-cjk-sans
    # Icon fonts
    papirus-icon-theme
    noto-fonts-emoji
    # Git
    git
    delta
    difftastic
    git-lfs
    gh
    gh-dash
    # jujutsu
    # Docker
    docker
    # docker-compose
    lazydocker
    # Sql
    # sqlite
    # Miscelanious
    nix-search-cli
    tree
    tokei
    upiano
    peaclock
    # Battery management
    tlp
    powertop
    # Device monitoring
    bottom
    macchina
    dust
    # Audio
    pipewire
    wireplumber
    pulsemixer
    # Brightness
    brightnessctl
    # Screenshots
    slurp
    grim
    swappy
    # Screen recording
    slurp
    wl-screenrec
    ffmpeg
    # Base linux stuff
    coreutils
    # Steam
    steam
    protonplus
    gamemode
    # Languages
    # grpc-tools
    ## Markdown
    marksman
    dprint
    ## Toml
    taplo
    ## Nix
    nil
    alejandra
    ## Python
    python312Full
    ruff
    ruff-lsp
    python312Packages.python-lsp-server
    python312Packages.python-lsp-ruff
    pyright
    black
    uv
    # python312Packages.debugpy
    # pipx
    # stdenv.cc.cc.lib
    # glib.out
    # libGL
    # Bash
    bash-language-server
    ## Go
    go
    pkg-config
    alsa-lib
    portaudio
    gopls
    golangci-lint
    protoc-gen-go
    protoc-gen-go-grpc
    delve
    ## Typescript
    typescript
    biome
    typescript-language-server
    yarn
    nodejs_22
    # ##Julia
    # julia
    # # Elixir
    # elixir
    # erlang
    # elixir-ls
    # ## Arduino
    # arduino-ide
    # arduino-cli
    # arduino-mk
    # # Raspberry
    # rpiboot
    # rpi-imager
    # ## Kotlin
    # kotlin-language-server
    # ktfmt
    # android-tools
    # ## Flutter
    # flutter
    # dart
    # # Rust
    # rustup
    # cargo
    # ## C
    # clang-tools_18
    # lldb
    # ## C-Sharp
    # omnisharp-roslyn
    # netcoredbg
  ];
}
