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

  # Display Manager & Desktop
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

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
  ];

  system.stateVersion = vars.stateVersion;
}
