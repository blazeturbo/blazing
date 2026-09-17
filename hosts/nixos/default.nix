{ config, pkgs, inputs, ... }:
let
  vars = import ../../variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/niri.nix
    ../../modules/core/nvidia.nix
    ../../modules/core/scheduler.nix
    ../../modules/core/stylix.nix
    ../../modules/core/rainbow.nix
  ];

  # Allow unfree packages (required for NVIDIA drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # Enable Nix flakes and nix-command
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Bootloader & Kernel
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = vars.hostname;
  networking.networkmanager.enable = true;

  # Time & Locale
  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "fr_FR.UTF-8";
    LC_IDENTIFICATION = "fr_FR.UTF-8";
    LC_MEASUREMENT = "fr_FR.UTF-8";
    LC_MONETARY = "fr_FR.UTF-8";
    LC_NAME = "fr_FR.UTF-8";
    LC_NUMERIC = "fr_FR.UTF-8";
    LC_PAPER = "fr_FR.UTF-8";
    LC_TELEPHONE = "fr_FR.UTF-8";
    LC_TIME = "fr_FR.UTF-8";
  };

  # Display Manager: Ly TUI Login Manager with Matrix animation & big clock (Themed by Stylix)
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;
  services.displayManager.ly = {
    enable = true;
    settings = let
      c = config.lib.stylix.colors;
    in {
      animation = "matrix";
      bigclock = "en";
      clock = "%a %b %d %H:%M";
      full_color = true;
      bg = "0x00" + c.base00;
      fg = "0x00" + c.base05;
      border_fg = "0x00" + c.base0D;
      error_fg = "0x01" + c.base08;
      cmatrix_fg = "0x00" + c.base0B;
      cmatrix_head_col = "0x01" + c.base07;
    };
  };

  # Keyboard layout
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Printing & Audio
  services.printing.enable = true;
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # User account
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [ "networkmanager" "wheel" "video" ];
  };

  # Programs & System packages
  programs.nix-ld.enable = true;
  programs.firefox.enable = true;

  environment.systemPackages = with pkgs; [
    git
    wget
    curl
    killall
    vim
    pciutils
    fastfetch
    yazi
    cmatrix
    swaybg
    power-profiles-daemon
  ];

  system.stateVersion = vars.stateVersion;
}
