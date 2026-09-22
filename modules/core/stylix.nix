{ pkgs, ... }:
let
  inherit (import ../../variables.nix) stylixImage;
in {
  stylix = {
    enable = true;
    image = stylixImage;
    polarity = "dark";
    opacity.terminal = 0.90;
    # No cursor set here on purpose: the Catppuccin Mocha Light theme
    # lives in ~/.local/share/icons and is picked up via XCURSOR_THEME
    # (see environment.sessionVariables in hosts/nixos/default.nix).
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.caskaydia-cove;
        name = "CaskaydiaCove Nerd Font Mono";
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
