{ config, pkgs, inputs, ... }:
let
  vars = import ../../variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/blazing.nix
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

  # Bootloader (kernel comes from modules/core/blazing.nix)
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

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

  # Audio (printing removed — no printer on this machine)
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Swap left/right channels on every output (wired, USB, HDMI, BT):
    # telling WirePlumber the first hardware channel is FR (not FL)
    # routes left content to the physical right ear and vice versa.
    # Native WirePlumber rule, no extra packages.
    wireplumber.extraConfig."51-swap-channels" = {
      "monitor.alsa.rules" = [
        {
          matches = [{ "node.name" = "~alsa_output.*"; }];
          actions = {
            update-props = {
              "audio.position" = [ "FR" "FL" ];
            };
          };
        }
      ];
      "monitor.bluez.rules" = [
        {
          matches = [{ "node.name" = "~bluez_output.*"; }];
          actions = {
            update-props = {
              "audio.position" = [ "FR" "FL" ];
            };
          };
        }
      ];
    };
  };

  # Enable zsh system-wide (required for it to be a valid login shell)
  programs.zsh.enable = true;

  # GameMode: on-demand gaming tweaks (perf governor, higher priority).
  # Sober already requests it; this makes the request actually work.
  # Declarative: survives rebuilds and flake updates untouched.
  programs.gamemode.enable = true;

  # CPU at full ramp, always: sustained high clocks in games instead of
  # parking at the 800 MHz floor under load. Safe (stock Intel p-state,
  # no overclock, no voltage changes); costs warmer idle + more fan.
  # Declarative: survives rebuilds and flake updates untouched.
  powerManagement.cpuFreqGovernor = "performance";

  # User account
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [ "networkmanager" "wheel" "video" ];
    shell = pkgs.zsh;
  };

  # Programs & System packages
  programs.nix-ld.enable = true;

  # Polkit: lets privileged GUIs (e.g. input-remapper) ask for auth.
  # enablePkexecWrapper makes /run/wrappers/bin/pkexec setuid root —
  # without it the remapper GUI dies with "pkexec must be setuid root".
  security.polkit.enable = true;
  security.polkit.enablePkexecWrapper = true;

  # No local manual (removes the "NixOS Manual" launcher entry too)
  documentation.nixos.enable = false;

  # Lets AppImages (e.g. ~/Applications/helium-*.AppImage) actually execute.
  # This only provides the runner — Helium itself stays a plain file in
  # your home directory, nothing of it enters the Nix store.
  programs.appimage = {
    enable = true;
    binfmt = true;
  };

  # Flatpak apps support + the Flathub remote declared once, so it
  # survives rebuilds (plain `flatpak remote-add` alone would too, but
  # this way a fresh machine gets it automatically).
  services.flatpak.enable = true;
  systemd.services.flatpak-add-flathub = {
    description = "Add Flathub remote if missing";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    path = with pkgs; [ flatpak ];
    script = ''
      flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
    '';
    serviceConfig.Type = "oneshot";
  };

  # Custom cursor from ~/.local/share/icons (NOT the Nix store on purpose)
  environment.sessionVariables = {
    XCURSOR_THEME = "catppuccin-mocha-light-cursors";
    XCURSOR_SIZE = "24";
  };

  # NOTE: the `fastfetch` binary stays on purpose: fastfetch2 IS
  # fastfetch-powered (its info panel + spinning logo both call it).
  # Removing it would break fastfetch2.
  environment.systemPackages = with pkgs; [
    git
    curl
    fastfetch
    yazi
    cmatrix
    swaybg
    awww # wallpaper daemon (pkgs.swww is just an alias of this)
    eza
    bat
    btop
    cava
    equibop
    discord
    opencode-desktop
    obs-studio
    tty-clock
    lavat
    mpv
    hyprpolkitagent # polkit auth dialog agent (no desktop file clutter)
  ];

  # 8GB swapfile safety net (root is ext4, so this just works;
  # NixOS creates, formats, and activates it automatically).
  swapDevices = [{ device = "/swapfile"; size = 8 * 1024; }];

  system.stateVersion = vars.stateVersion;
}
