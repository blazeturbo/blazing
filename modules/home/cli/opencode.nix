# opencode CLI (terminal), pinned via the opencode-pin flake input.
# This is the exact equivalent of
#   nix shell github:NixOS/nixpkgs/590d72952b052366ecf4060c8bf711d7f2b0d249#opencode
# but declarative: `opencode` is on PATH after every rebuild, no shell
# wrapper needed. Deliberately NOT pkgs.opencode (broken upstream) and
# NOT opencode-desktop (GUI, not wanted).
{ pkgs, inputs, ... }:
let
  pin = inputs.opencode-pin.legacyPackages.${pkgs.stdenv.hostPlatform.system};
in {
  home.packages = [ pin.opencode ];
}
