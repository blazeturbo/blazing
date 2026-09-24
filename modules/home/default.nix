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
    ./dms-theme.nix
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
    "applications/qt5ct.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/qt6ct.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/kvantummanager.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/nvidia-settings.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    # kew is terminal-only (`kew` in kitty) — no launcher entry needed.
    "applications/kew.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/mpv.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
    "applications/umpv.desktop".text = "[Desktop Entry]\nNoDisplay=true\n";
  };

  home.stateVersion = "26.05";
}
