{ pkgs, ... }:
let
  inherit (import ../../variables.nix) stylixImage;
in {
  stylix = {
    enable = true;
    image = stylixImage;
    polarity = "dark";
    opacity.terminal = 0.90;
    # No cursor set here on purpose: home.pointerCursor owns the
    # Catppuccin Mocha Rosewater theme (see modules/home/stylix.nix).
    fonts = {
      monospace = {
        package = pkgs.callPackage ./fonts/jetbrains-mono-nerd.nix { };
        name = "JetBrainsMono Nerd Font Mono";
      };
      sansSerif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      serif = {
        package = pkgs.montserrat;
        name = "Montserrat";
      };
      sizes = {
        applications = 12;
        terminal = 14;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
