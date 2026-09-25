# User-provided fonts, installed system-wide. The TTFs live beside their
# derivations (see jetbrains-mono-nerd.nix). DejaVu stays as a fallback
# for glyphs JetBrains doesn't cover.
{ pkgs, ... }:
{
  fonts.packages = with pkgs; [
    (callPackage ./jetbrains-mono-nerd.nix { })
    nerd-fonts.dejavu-sans-mono
  ];
}
