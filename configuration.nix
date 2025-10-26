{
  config,
  pkgs,
  lib,
  ...
}: {
  # nix PROGRAM CONFIGURATION
  imports = [
    ./dotfiles/gdm.nix
    ./secrets/sopsnix.nix
    ./dotfiles/kanata.nix
    ./dotfiles/udisks.nix
    ./dotfiles/upower.nix
    ./dotfiles/fcitx5.nix
    ./dotfiles/fish.nix
    # ./dotfiles/restic.nix # Disabled until I understand secret management better
  ];

  # non-nix PROGRAM CONFIGURATION
  #   dotfiles/*/**
  #   scripts/stow.sh
  #   scripts_as_dotfiles/*/**

  # PROGRAM INSTALLATION
  config.environment.systemPackages = with pkgs; [
    # Backups
    restic
    # Api key management
    sops # + sops-nix (which had to be installed as a flake input)
    age
    ripsecrets
    # 2FA for websites that require an authenticator app
    totp-cli
    # Dotfiles symlinking
    stow
    # Keyboard remapper
    kanata-with-cmd
    # Mounting devices
    udisks
    android-file-transfer
    bashmount # Manually mount
    # Wayland
    wayland
    wl-clipboard
    # Displays
    wlr-randr
    wl-mirror
    # Display manager (For logging in)
    gdm
    # Compositor
    river-classic # Similar to i3/sway. Aside from to set scratchpads, I use it the same as i3/sway.
    sway
    # Widgets, status bars...
    quickshell
    kdePackages.qtdeclarative
    upower
    # Notifications
    mako
    libnotify
    # Terminal multiplexer
    tmux
    tmuxPlugins.sensible
    tmuxPlugins.tmux-fzf
    sesh
    # IDE
    helix
    neovim # I don't use it anymore but I realize a majority of people who might try this setup do use it.
    lazygit
    zed-editor # For debuggers.
    scooter # Allows global search-and-replace within helix
    # AI assistant
    aichat # with yek+jaq (jq) for feeding it a whole codebase
    claude-code
    yek
    jaq
    # App launcher
    fuzzel
    # Terminal
    foot
    ghostty
    # Interactive shell
    fish
    atuin
    # Login shell - scripts
    bash
    # Tools I use with scripts
    gum
    jaq
    ripgrep
    fzf
    zoxide
    fd
    scc
    youplot
    showmethekey
    # File manager tui
    yazi
    # File manager gui
    nautilus
    # Browser
    (pkgs.wrapFirefox (pkgs.firefox-unwrapped.override {pipewireSupport = true;}) {})
    brave
    # RSS
    newsraft
    # Pdfs
    sioyek
    xournalpp
    # Western fonts
    hack-font
    # Eastern fonts
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
    # Docker
    docker
    # Sql
    sqlite
    # Battery management
    tlp
    powertop
    # Device monitoring
    bottom
    dust
    microfetch
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
    vokoscreen-ng
    ffmpeg
    # Video player
    mpv
    # Base linux stuff
    # uutils-coreutils
    coreutils
    # Miscelanious
    nix-search-cli
    awscli2
    tree
    tty-clock
    libreoffice
    # Languages
    ## Python
    python313
    ruff
    pylyzer
    pyright
    uv
    stdenv.cc
    # Bash
    bash-language-server
    ## Go
    go
    gopls
    golangci-lint
    protobuf
    protoc-gen-go
    protoc-gen-go-grpc
    delve
    stdenv.cc
    ## Typescript
    typescript
    biome
    typescript-language-server
    yarn
    nodejs_22
    ## Nix
    nil
    alejandra
    ## Markdown
    marksman
    ltex-ls
    inlyne
    ## Toml
    taplo
    # # Kotlin
    # kotlin
    # kotlin-language-server
    # ktfmt
    # android-tools
  ];

  # ENVIRONMENT VARIABLES
  config.environment.variables = {
    EDITOR = "hx";
    BROWSER = "firefox";
    TERMINAL = "ghostty";
    SHELL = "fish";
    XDG_CURRENT_DESKTOP = "river";
    XDG_SESSION_TYPE = "wayland";
    WAYLAND_DISPLAY = "wayland-1";
    WLR_RENDER_NO_EXPLICIT_SYNC = "1"; # Fixes flickering on zed? https://github.com/zed-industries/zed/issues/32792
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
  };
  config.boot.kernel.sysctl."kernel.yama.ptrace_scope" = 1; # Disable only while using the Go debugger

  # NIXOS CONFIGURATION VARIABLES
  options. userDefinedGlobalVariables = {
    username = lib.mkOption {
      default = "nixos"; # WARNING: Be careful before changing it.
      # The most problems I had with nixos was changing the username.
      # It is set with config.users.users.${config.userDefinedGlobalVariables.username}
      # https://gist.github.com/teknolog1k/32ec30d3a7fa9617d081a8cc2d82c8cf
      type = lib.types.str;
    };
  };
}
