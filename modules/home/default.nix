{ pkgs, ... }: {
  imports = [
    ./fastfetch
    ./yazi
    ./starship.nix
    ./stylix.nix
    ./noctalia.nix
    ./niri
    ./kitty.nix
  ];

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    wl-clipboard
    libnotify
  ];

  home.stateVersion = "26.05";
}
