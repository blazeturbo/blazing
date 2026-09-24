{ pkgs, ... }:
let
  inherit (import ../../variables.nix) stylixImage;
in {
  stylix = {
    enable = true;
    image = stylixImage;
    polarity = "dark";
    # Hardcoded accents: the genetic generator can't invent hues that
    # aren't in the wallpaper, so on near-monochrome images it fills
    # every accent slot with reds. These teals are lifted straight from
    # the wallpaper family at accent lightness; base08 keeps the
    # signal-light red so errors still read as errors. Temporary by
    # design — delete this block when the wallpaper changes.
    override = {
      base08 = "A54B3B";
      base09 = "507F89";
      base0A = "6AA5B0";
      base0B = "538D97";
      base0C = "41686F";
      base0D = "51828D";
      base0E = "6E9AA3";
    };
    opacity.terminal = 0.90;
    # No cursor set here on purpose: the Catppuccin Mocha Light theme
    # lives in ~/.local/share/icons and is picked up via XCURSOR_THEME
    # (see environment.sessionVariables in hosts/nixos/default.nix).
    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.dejavu-sans-mono;
        name = "DejaVuSansM Nerd Font Mono";
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
