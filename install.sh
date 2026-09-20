#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/blazeturbo/os.git"
DEST="$HOME/.config/nixos"
USERNAME=""
HOSTNAME=""
TIMEZONE=""
GPU=""
BOOT=""
DISK=""
YES=0
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
    --gpu) GPU="$2"; shift 2 ;;
    --boot) BOOT="$2"; shift 2 ;;
    --disk) DISK="$2"; shift 2 ;;
    --yes) YES=1; shift ;;
    --no-switch) SWITCH=0; shift ;;
    -h|--help) usage 0 ;;
    *) echo "Unknown option: $1 (see --help)" >&2; exit 1 ;;
  esac
done

log() { printf '[install] %s\n' "$*"; }
die() { printf '[install] ERROR: %s\n' "$*" >&2; exit 1; }

prompt() {
  local var="$1" text="$2" def="$3" val=""
  if [ -t 0 ]; then
    printf '%s [%s]: ' "$text" "$def" >&2
    IFS= read -r val || val=""
    [ -z "$val" ] && val="$def"
  else
    val="$def"
  fi
  printf -v "$var" '%s' "$val"
}

detect_timezone() {
  local tz=""
  tz="$(timedatectl show -p Timezone --value 2>/dev/null)" || tz=""
  if [ -z "$tz" ] && [ -L /etc/localtime ]; then
    tz="$(readlink /etc/localtime 2>/dev/null | sed 's|.*/zoneinfo/||')"
  fi
  [ -n "$tz" ] && [ -f "/usr/share/zoneinfo/$tz" ] && printf '%s' "$tz" && return 0
  printf 'Europe/Paris'
}

detect_disk() {
  local src pk=""
  src="$(findmnt -no SOURCE / 2>/dev/null)" || src=""
  [ -n "$src" ] && pk="$(lsblk -no PKNAME "$src" 2>/dev/null)"
  [ -n "$pk" ] && printf '/dev/%s' "$pk" && return 0
  return 1
}

set_var() {
  local key="$1" val="$2" f="variables.nix"
  if grep -q "^  $key = " "$f"; then
    sed -i "s|^  $key = .*|  $key = \"$val\";|" "$f"
  else
    sed -i "\$i\\  $key = \"$val\";" "$f"
  fi
  grep -q "^  $key = \"$val\";" "$f" || die "failed writing $key to variables.nix."
}

[ -f /etc/NIXOS ] || die "not a NixOS system (/etc/NIXOS missing)."
command -v git >/dev/null || die "git not found (try: nix-shell -p git)."
command -v nix >/dev/null || die "nix not found."
export NIX_CONFIG="experimental-features = nix-command flakes"

[ -z "$USERNAME" ] && USERNAME="$USER"
[ -z "$HOSTNAME" ] && HOSTNAME="$(cat /etc/hostname 2>/dev/null || hostname)"
[ -z "$TIMEZONE" ] && TIMEZONE="$(detect_timezone)"
[ -z "$GPU" ] && GPU="nvidia"
[ -z "$BOOT" ] && BOOT="uefi"

while true; do
  [ -z "$USERNAME" ] && prompt USERNAME "Username" "$USER"
  case "$USERNAME" in
    ''|*[!a-z0-9_-]*|[-_]) log "letters, digits, _ and - only, please."; USERNAME="" ;;
    *) break ;;
  esac
done
prompt HOSTNAME "Hostname" "$HOSTNAME"
while true; do
  [ -z "$TIMEZONE" ] && prompt TIMEZONE "Timezone" "$(detect_timezone)"
  if [ -f "/usr/share/zoneinfo/$TIMEZONE" ]; then break; fi
  log "unknown timezone, check /usr/share/zoneinfo for names."
  TIMEZONE=""
done
GPU="$(printf '%s' "$GPU" | tr '[:upper:]' '[:lower:]')"
while true; do
  [ -z "$GPU" ] && prompt GPU "GPU (nvidia/amd/intel)" "nvidia"
  case "$GPU" in
    nvidia|amd|intel) break ;;
    *) log "answer nvidia, amd or intel."; GPU="" ;;
  esac
done
BOOT="$(printf '%s' "$BOOT" | tr '[:upper:]' '[:lower:]')"
while true; do
  [ -z "$BOOT" ] && prompt BOOT "Boot mode (uefi/bios)" "uefi"
  case "$BOOT" in
    uefi|bios) break ;;
    *) log "answer uefi or bios."; BOOT="" ;;
  esac
done
if [ "$BOOT" = bios ]; then
  [ -z "$DISK" ] && DISK="$(detect_disk || true)"
  while true; do
    [ -z "$DISK" ] && prompt DISK "Install disk (grub goes here)" "${DISK:-/dev/sda}"
    case "$DISK" in
      /dev/*) ;;
      *) DISK="/dev/$DISK" ;;
    esac
    if [ -e "$DISK" ]; then break; fi
    log "$DISK not found, check lsblk."
    DISK=""
  done
fi

log "---"
log "repo:     $REPO_URL"
log "dir:      $DEST"
log "username: $USERNAME"
log "hostname: $HOSTNAME"
log "timezone: $TIMEZONE"
log "gpu:      $GPU"
log "boot:     $BOOT"
[ "$BOOT" = bios ] && log "disk:     $DISK"
log "---"
if [ "$YES" -eq 0 ] && [ -t 0 ]; then
  printf 'Go ahead with the install? [Y/n]: ' >&2
  IFS= read -r go || go=""
  case "$go" in
    ''|[Yy]*) ;;
    *) die "aborted." ;;
  esac
fi

if [ -e "$DEST" ] && [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
  die "$DEST exists and is not empty - move it aside first."
fi

log "cloning $REPO_URL -> $DEST"
git clone "$REPO_URL" "$DEST"
cd "$DEST"

log "writing variables.nix"
set_var username "$USERNAME"
set_var hostname "$HOSTNAME"
set_var timezone "$TIMEZONE"
set_var gpu "$GPU"
set_var bootloader "$([ "$BOOT" = uefi ] && printf 'systemd-boot' || printf 'grub')"
[ "$BOOT" = bios ] && set_var grubDevice "$DISK"

if [ "$GPU" != nvidia ]; then
  log "heads up: this repo currently assumes an NVIDIA card."
  log "per-GPU module switching lands next - until then, expect breakage past this point."
fi
if [ "$BOOT" != uefi ]; then
  log "heads up: grub wiring for BIOS boot lands next - UEFI works today."
fi

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
