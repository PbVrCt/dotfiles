{pkgs, ...}: {
  # Audio, video
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
  };

  # Battery
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      # CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_AC = "powersave";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
      CPU_ENERGY_PERF_POLICY_ON_AC = "power";
      # CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 20;
    };
  };

  # Bluetooth
  hardware.bluetooth.enable = false;
  services.blueman.enable = false;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Fonts
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      hack-font
      papirus-icon-theme
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
    ];
  };

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "03:05";
    options = "--delete-older-than 15d";
  };
  nix.optimise = {
    automatic = true;
    dates = ["03:20"];
  };

  # Graphics
  hardware.graphics.enable = true;

  # Locale
  time.timeZone = "Asia/Tokyo";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ja_JP.UTF-8";
    LC_IDENTIFICATION = "ja_JP.UTF-8";
    LC_MEASUREMENT = "ja_JP.UTF-8";
    LC_MONETARY = "ja_JP.UTF-8";
    LC_NAME = "ja_JP.UTF-8";
    LC_NUMERIC = "ja_JP.UTF-8";
    LC_PAPER = "ja_JP.UTF-8";
    LC_TELEPHONE = "ja_JP.UTF-8";
    LC_TIME = "ja_JP.UTF-8";
  };

  # Networking
  networking = {
    hostName = "nixos";
    wireless.enable = false;
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # No password
  security.sudo.wheelNeedsPassword = false; # wheel group users don't need password

  # Enable the OpenSSH daemon. (I don't know what this does, copied it from somewhere)
  services.openssh.enable = true;

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  # Printing
  services.printing.enable = true;

  # Allow unfree
  nixpkgs.config.allowUnfree = true;

  # Docker
  virtualisation.docker.enable = true;

  # Xdg
  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-wlr
      kdePackages.xdg-desktop-portal-kde
      xdg-desktop-portal-gtk
    ];
  };

  # Stuff needed for Wayland. The name is misleading, it includes things for both X11 and Wayland. It hasn't been deprecated because of backwards compatiblity.
  services.xserver.enable = true;
  # # Disable X11 libraries: Does not work yet
  # environment.noXlibs = true;
  # nixpkgs.config.packageOverrides = pkgs: {
  #   pipewire = pkgs.pipewire.override { x11Support = false; };
  # };
}
