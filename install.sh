#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/blazeturbo/os.git"
DEST="$HOME/.config/nixos"
USERNAME="$USER"
HOSTNAME="$(cat /etc/hostname 2>/dev/null || hostname)"
TIMEZONE=""
SWITCH=1

usage() {
  echo "See README.md (Fresh machine install) for usage."
  exit "${1:-0}"
}

while [ $# -gt 0 ]; do
  case "$1" in
    --repo) REPO_URL="$2"; shift 2 ;;
    --dir) DEST="$2"; shift 2 ;;
    --username) USERNAME="$2"; shift 2 ;;
    --hostname) HOSTNAME="$2"; shift 2 ;;
    --timezone) TIMEZONE="$2"; shift 2 ;;
    --no-switch) SWITCH=0; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1 (see --help)" >&2; exit 1 ;;
  esac
done

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }

[ -f /etc/NIXOS ] || die "not a NixOS system (/etc/NIXOS missing)."
command -v git >/dev/null || die "git not found (try: nix-shell -p git)."
command -v nix >/dev/null || die "nix not found."
export NIX_CONFIG="experimental-features = nix-command flakes"

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  die "$DEST exists and is not empty - move it aside first."
fi

log "cloning $REPO_URL -> $DEST"
git clone "$REPO_URL" "$DEST"
cd "$DEST"

log "setting username=$USERNAME hostname=$HOSTNAME in variables.nix"
sed -i "s|^[[:space:]]*username = .*|  username = \"$USERNAME\";|" variables.nix
sed -i "s|^[[:space:]]*hostname = .*|  hostname = \"$HOSTNAME\";|" variables.nix
if [ -n "$TIMEZONE" ]; then
  sed -i "s|^[[:space:]]*timezone = .*|  timezone = \"$TIMEZONE\";|" variables.nix
fi
grep -q "^  username = \"$USERNAME\";" variables.nix || die "username substitution failed."
grep -q "^  hostname = \"$HOSTNAME\";" variables.nix || die "hostname substitution failed."

log "regenerating hardware-configuration.nix for this machine"
cp hosts/nixos/hardware-configuration.nix /tmp/hardware-configuration.nix.bak
sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
log "previous file backed up to /tmp/hardware-configuration.nix.bak (do not use it)"

log "checking flake evaluates"
nix flake check --no-build --flake "$DEST" >/dev/null \
  || die "flake check failed - fix errors before switching."

if [ "$SWITCH" -eq 1 ]; then
  log "switching to the new system (this takes a while on first run)"
  sudo nixos-rebuild switch --flake "$DEST#$HOSTNAME"
  log "done - reboot recommended."
else
  log "skipping switch (--no-switch). When ready:"
  log "  sudo nixos-rebuild switch --flake \"$DEST#$HOSTNAME\""
fi
