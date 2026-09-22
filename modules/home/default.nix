{ pkgs, inputs, ... }: {
  imports = [
    # Spotify/spicetify DISABLED on this machine (kew won) but kept in
    # the repo for others: ./spicetify.nix + spicetify-text/ are intact,
    # re-add the two lines below to bring it back.
    # inputs.spicetify-nix.homeManagerModules.default
    ./fastfetch
    ./yazi
    ./starship.nix
    ./stylix.nix
    ./noctalia.nix
    ./niri
    ./kitty.nix
    ./zsh.nix
    ./eza.nix
    ./zoxide.nix
    ./cli/bat.nix
    ./cli/btop.nix
    ./cli/cava.nix
    ./cli/cliphist.nix
    ./cli/eyecandy.nix
    ./cli/git.nix
    ./cli/music.nix
    ./cli/opencode.nix
    ./discord.nix
  ];

  programs.home-manager.enable = true;

  # zsh replaces bash as the interactive shell (no fastfetch autostart —
  # run `fastfetch` manually when you want it, starship stays always-on)
  programs.bash = {
    enable = false;
  };

  home.packages = with pkgs; [
    wl-clipboard
    libnotify
    cava
    ripgrep
    fd
    unzip
    unrar
    cmatrix
    eza
    # Sober launcher: ALWAYS through gamemoderun (perf governor +
    # max NVIDIA PowerMizer on-demand, idle untouched). Terminal +
    # scripts use `sober`; GUI uses the desktop override below.
    (writeShellScriptBin "sober" ''
      exec ${gamemode}/bin/gamemoderun flatpak run --branch=stable --arch=x86_64 --command=sober --file-forwarding org.vinegarhq.Sober -- "$@"
    '')
  ];

  # Default browser = Helium (AppImage, registered via
  # ~/.local/share/applications/helium.desktop).
  # There was no default set anywhere before — this is the place.
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = [ "helium.desktop" ];
      "application/xhtml+xml" = [ "helium.desktop" ];
      "x-scheme-handler/http" = [ "helium.desktop" ];
      "x-scheme-handler/https" = [ "helium.desktop" ];
    };
  };

  # Hide launcher entries you never open directly (launched via
  # keybinds/services instead). A stub with NoDisplay shadows the real
  # file without touching any package.
  xdg.dataFile = {
    "applications/btop.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/kitty.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/dev.noctalia.Noctalia.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/qt5ct.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/qt6ct.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/kvantummanager.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/nvidia-settings.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    # kew is terminal-only (`kew` in kitty) — no launcher entry needed.
    "applications/kew.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    # Sober override: shadow the flatpak export so EVERY GUI launch
    # (launcher, mime handler, autostart) goes through gamemoderun.
    # ~/.local/share/applications wins over /var/lib/flatpak/exports.
    # No idle cost: GameMode engages only while Sober runs.
    "applications/org.vinegarhq.Sober.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Sober
      GenericName=Roblox Player
      Comment=Play, chat & explore on Roblox
      Icon=org.vinegarhq.Sober
      Keywords=roblox;vinegar;game;gaming;social;experience;launcher;
      MimeType=x-scheme-handler/roblox;x-scheme-handler/roblox-player;
      Categories=GNOME;GTK;Game;
      Terminal=false
      PrefersNonDefaultGPU=true
      SingleMainWindow=true
      Exec=gamemoderun flatpak run --branch=stable --arch=x86_64 --command=sober --file-forwarding org.vinegarhq.Sober -- @@u %u @@
      Actions=open-settings;
      X-Flatpak-Tags=proprietary;
      X-Flatpak=org.vinegarhq.Sober

      [Desktop Action open-settings]
      Name=Settings
      Exec=gamemoderun flatpak run --branch=stable --arch=x86_64 --command=sober org.vinegarhq.Sober config
    '';
    "applications/mpv.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/umpv.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
  };

  home.stateVersion = "26.05";
}
