{ config, pkgs, inputs, lib, ... }:
let
  vars = import ../../variables.nix;
in {
  imports = [
    ./hardware-configuration.nix
    ../../modules/core/blazing.nix
    ../../modules/core/niri.nix
    ../../modules/core/network.nix
    ../../modules/core/nvidia.nix
    ../../modules/core/scheduler.nix
    ../../modules/core/performance.nix
    ../../modules/core/sddm.nix
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

  # Display Manager, picked by variables.nix loginManager ("ly" | "sddm"
  # | "pixie"). Ly: TUI login with Matrix animation & big clock (Stylix).
  # SDDM/pixie live in modules/core/sddm.nix; only one DM runs at a time.
  services.displayManager.gdm.enable = false;
  services.desktopManager.gnome.enable = false;
  services.displayManager.ly = lib.mkIf (vars.loginManager == "ly") {
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

  # GameMode: gaming tweaks while Sober runs (higher priority,
  # max NVIDIA PowerMizer). Governor stays `performance` always —
  # idle AND gaming, no powersave switching anywhere.
  # Sober is forced through `gamemoderun` via the desktop override +
  # `sober` wrapper in modules/home (so every launch path requests it).
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        desiredgov = "performance";
        defaultgov = "performance";
        softrealtime = "auto";
        renice = 10;
        ioprio = 0;
        inhibit_screensaver = 1;
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
        nv_powermizer_mode = 1;
        amd_performance_level = "high";
      };
    };
  };

  # Governor lives in modules/core/performance.nix behind
  # vars.performanceMode (true = performance always). Kept out of here
  # so the toggle is real: flipping it to false drops back to defaults.

  # User account
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.username;
    extraGroups = [ "networkmanager" "wheel" "video" "gamemode" ];
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

  # Flatpak NVIDIA GL/Vulkan runtimes, ALWAYS exactly matching the live
  # host driver: reads /sys/module/nvidia/version at boot (dots->dashes)
  # and installs that GL + GL32 runtime if missing. Sandboxed apps (Sober)
  # mount org.freedesktop.Platform.GL.nvidia-<host-version>; a mismatch
  # breaks their Vulkan. Self-maintaining across driver updates — no
  # manual version bumps. If Flathub hasn't published the brand-new
  # runtime yet, install is retried via the log message on next boot /
  # `flatpak update` picks it up once published.
  systemd.services.flatpak-nvidia-match = {
    description = "Install Flatpak NVIDIA GL runtimes matching host driver";
    wantedBy = [ "multi-user.target" ];
    after = [ "flatpak-add-flathub.service" "network-online.target" ];
    wants = [ "network-online.target" ];
    requires = [ "flatpak-add-flathub.service" ];
    path = with pkgs; [ flatpak ];
    script = ''
      ver=$(tr '.' '-' < /sys/module/nvidia/version)
      for ref in \
        "org.freedesktop.Platform.GL.nvidia-$ver" \
        "org.freedesktop.Platform.GL32.nvidia-$ver"; do
        if flatpak info "$ref" >/dev/null 2>&1; then
          echo "$ref already installed"
        else
          echo "installing $ref to match host driver"
          flatpak install -y flathub "$ref" || echo "WARN: $ref not on Flathub yet, will retry next boot"
        fi
      done >>/var/log/flatpak-nvidia-match.log 2>&1 || true
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
    gh # github CLI (releases, uploads)
    curl
    fastfetch
    vscodium
    yazi
    cmatrix
    swaybg
    awww # wallpaper daemon (pkgs.swww is just an alias of this)
    eza
    bat
    btop
    equibop
    cava
    discord
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
