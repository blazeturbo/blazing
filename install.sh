```bash
#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/blazeturbo/blazing.git"
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
    cat <<EOF
Usage: $0 [options]

Options:
  --repo URL          Repository to clone
  --dir PATH          Installation directory
  --username NAME     NixOS username
  --hostname NAME     System hostname
  --timezone TZ       System timezone
  --gpu GPU           GPU: nvidia, amd, or intel
  --boot MODE         Boot mode: uefi or bios
  --disk DEVICE       Install disk for BIOS/GRUB
  --yes               Skip confirmation prompt
  --no-switch         Do not run nixos-rebuild switch
  -h, --help          Show this help

Examples:

  $0

  $0 --gpu nvidia

  $0 --gpu nvidia --boot uefi --yes

  $0 --gpu amd --hostname gaming-pc
EOF
}

log() {
    printf '[install] %s\n' "$*"
}

die() {
    printf '[install] ERROR: %s\n' "$*" >&2
    exit 1
}

prompt() {
    local var="$1"
    local text="$2"
    local default="${3:-}"
    local value=""

    if [ -t 0 ]; then
        if [ -n "$default" ]; then
            printf '%s [%s]: ' "$text" "$default" >&2
        else
            printf '%s: ' "$text" >&2
        fi

        IFS= read -r value || value=""

        if [ -z "$value" ] && [ -n "$default" ]; then
            value="$default"
        fi
    else
        value="$default"
    fi

    printf -v "$var" '%s' "$value"
}

detect_timezone() {
    local tz=""

    tz="$(timedatectl show -p Timezone --value 2>/dev/null || true)"

    if [ -z "$tz" ] && [ -L /etc/localtime ]; then
        tz="$(readlink /etc/localtime 2>/dev/null || true)"
        tz="${tz#*/zoneinfo/}"
    fi

    if [ -n "$tz" ] && [ -f "/usr/share/zoneinfo/$tz" ]; then
        printf '%s' "$tz"
        return 0
    fi

    printf '%s' "Europe/Paris"
}

detect_hostname() {
    local hostname=""

    hostname="$(cat /etc/hostname 2>/dev/null || true)"

    if [ -n "$hostname" ]; then
        printf '%s' "$hostname"
    else
        hostname="$(hostname 2>/dev/null || true)"
        printf '%s' "${hostname:-nixos}"
    fi
}

detect_disk() {
    local source=""
    local parent=""

    source="$(findmnt -no SOURCE / 2>/dev/null || true)"

    if [ -z "$source" ]; then
        return 1
    fi

    parent="$(lsblk -no PKNAME "$source" 2>/dev/null || true)"

    if [ -n "$parent" ]; then
        printf '/dev/%s' "$parent"
        return 0
    fi

    return 1
}

valid_username() {
    [[ "$1" =~ ^[a-z_][a-z0-9_-]*$ ]]
}

valid_hostname() {
    [[ "$1" =~ ^[a-zA-Z0-9][a-zA-Z0-9.-]*$ ]]
}

valid_timezone() {
    [ -f "/usr/share/zoneinfo/$1" ]
}

valid_gpu() {
    case "$1" in
        nvidia|amd|intel)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

valid_boot() {
    case "$1" in
        uefi|bios)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

normalize_gpu() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

normalize_boot() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

set_var() {
    local key="$1"
    local value="$2"
    local file="variables.nix"

    [ -f "$file" ] || die "$file not found."

    # Escape characters that are special inside a Nix string.
    local escaped
    escaped="${value//\\/\\\\}"
    escaped="${escaped//\"/\\\"}"

    if grep -qE "^  ${key} =" "$file"; then
        sed -i \
            "s|^  ${key} = .*|  ${key} = \"${escaped}\";|" \
            "$file"
    else
        sed -i \
            "\$i\\  ${key} = \"${escaped}\";" \
            "$file"
    fi

    grep -qF "  ${key} = \"${escaped}\";" "$file" \
        || die "Failed writing ${key} to ${file}."
}

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

while [ $# -gt 0 ]; do
    case "$1" in
        --repo)
            [ $# -ge 2 ] || die "--repo requires a value."
            REPO_URL="$2"
            shift 2
            ;;

        --dir)
            [ $# -ge 2 ] || die "--dir requires a value."
            DEST="$2"
            shift 2
            ;;

        --username)
            [ $# -ge 2 ] || die "--username requires a value."
            USERNAME="$2"
            shift 2
            ;;

        --hostname)
            [ $# -ge 2 ] || die "--hostname requires a value."
            HOSTNAME="$2"
            shift 2
            ;;

        --timezone)
            [ $# -ge 2 ] || die "--timezone requires a value."
            TIMEZONE="$2"
            shift 2
            ;;

        --gpu)
            [ $# -ge 2 ] || die "--gpu requires a value."
            GPU="$2"
            shift 2
            ;;

        --boot)
            [ $# -ge 2 ] || die "--boot requires a value."
            BOOT="$2"
            shift 2
            ;;

        --disk)
            [ $# -ge 2 ] || die "--disk requires a value."
            DISK="$2"
            shift 2
            ;;

        --yes)
            YES=1
            shift
            ;;

        --no-switch)
            SWITCH=0
            shift
            ;;

        -h|--help)
            usage
            exit 0
            ;;

        *)
            die "Unknown option: $1 (use --help)."
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Environment checks
# ---------------------------------------------------------------------------

[ -f /etc/NIXOS ] \
    || die "This does not appear to be a NixOS system (/etc/NIXOS missing)."

command -v git >/dev/null 2>&1 \
    || die "git is not installed. Install it first."

command -v nix >/dev/null 2>&1 \
    || die "nix is not installed."

command -v sudo >/dev/null 2>&1 \
    || die "sudo is not installed."

export NIX_CONFIG="experimental-features = nix-command flakes"

# ---------------------------------------------------------------------------
# Defaults that are safe to detect automatically
# ---------------------------------------------------------------------------

[ -z "$USERNAME" ] && USERNAME="${USER:-}"

[ -z "$HOSTNAME" ] && HOSTNAME="$(detect_hostname)"

[ -z "$TIMEZONE" ] && TIMEZONE="$(detect_timezone)"

[ -z "$BOOT" ] && BOOT="uefi"

# IMPORTANT:
# GPU intentionally has NO default.
#
# The user must explicitly select it.
# ---------------------------------------------------------------------------

# Username
while true; do
    if [ -z "$USERNAME" ]; then
        prompt USERNAME "Username" "${USER:-}"
    fi

    if valid_username "$USERNAME"; then
        break
    fi

    log "Invalid username."
    log "Use lowercase letters, digits, '_' and '-' and start with a letter or '_'."
    USERNAME=""
done

# Hostname
while true; do
    if [ -z "$HOSTNAME" ]; then
        prompt HOSTNAME "Hostname" "nixos"
    fi

    if valid_hostname "$HOSTNAME"; then
        break
    fi

    log "Invalid hostname."
    HOSTNAME=""
done

# Timezone
while true; do
    if [ -z "$TIMEZONE" ]; then
        prompt TIMEZONE "Timezone" "$(detect_timezone)"
    fi

    if valid_timezone "$TIMEZONE"; then
        break
    fi

    log "Unknown timezone: $TIMEZONE"
    log "Check /usr/share/zoneinfo for valid timezone names."
    TIMEZONE=""
done

# ---------------------------------------------------------------------------
# GPU -- MANDATORY
# ---------------------------------------------------------------------------

GPU="$(normalize_gpu "$GPU")"

while true; do
    if [ -z "$GPU" ]; then
        printf '\n'
        log "GPU selection is required."
        log "Available options: nvidia, amd, intel"
        prompt GPU "GPU" ""
        GPU="$(normalize_gpu "$GPU")"
    fi

    if valid_gpu "$GPU"; then
        break
    fi

    log "Invalid GPU: '$GPU'"
    log "Please enter exactly: nvidia, amd, or intel."
    GPU=""
done

# ---------------------------------------------------------------------------
# Boot mode
# ---------------------------------------------------------------------------

BOOT="$(normalize_boot "$BOOT")"

while true; do
    if [ -z "$BOOT" ]; then
        prompt BOOT "Boot mode (uefi/bios)" "uefi"
        BOOT="$(normalize_boot "$BOOT")"
    fi

    if valid_boot "$BOOT"; then
        break
    fi

    log "Invalid boot mode. Use 'uefi' or 'bios'."
    BOOT=""
done

# ---------------------------------------------------------------------------
# BIOS disk
# ---------------------------------------------------------------------------

if [ "$BOOT" = "bios" ]; then
    if [ -z "$DISK" ]; then
        DISK="$(detect_disk || true)"
    fi

    while true; do
        if [ -z "$DISK" ]; then
            prompt DISK "Install disk (GRUB target)" "/dev/sda"
        fi

        case "$DISK" in
            /dev/*)
                ;;
            *)
                DISK="/dev/$DISK"
                ;;
        esac

        if [ -b "$DISK" ]; then
            break
        fi

        log "$DISK is not a block device."
        log "Check your disks with: lsblk"
        DISK=""
    done
fi

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

printf '\n'

log "--- Installation configuration ---"
log "repo:      $REPO_URL"
log "directory: $DEST"
log "username:  $USERNAME"
log "hostname:  $HOSTNAME"
log "timezone:  $TIMEZONE"
log "gpu:       $GPU"
log "boot:      $BOOT"

if [ "$BOOT" = "bios" ]; then
    log "disk:      $DISK"
fi

log "----------------------------------"

if [ "$YES" -eq 0 ]; then
    if [ -t 0 ]; then
        printf 'Go ahead with the install? [Y/n]: ' >&2
        IFS= read -r answer || answer=""

        case "$answer" in
            ""|[Yy]|[Yy][Ee][Ss])
                ;;
            *)
                die "Aborted."
                ;;
        esac
    else
        die "Non-interactive mode requires --yes."
    fi
fi

# ---------------------------------------------------------------------------
# Destination checks
# ---------------------------------------------------------------------------

if [ -e "$DEST" ]; then
    if [ ! -d "$DEST" ]; then
        die "$DEST exists but is not a directory."
    fi

    if [ -n "$(ls -A "$DEST" 2>/dev/null)" ]; then
        die "$DEST exists and is not empty. Move it aside or choose another directory."
    fi
fi

# ---------------------------------------------------------------------------
# Clone
# ---------------------------------------------------------------------------

log "Cloning repository..."
git clone "$REPO_URL" "$DEST"

cd "$DEST"

[ -f variables.nix ] \
    || die "variables.nix was not found in the repository."

[ -d hosts/nixos ] \
    || die "hosts/nixos directory was not found."

# ---------------------------------------------------------------------------
# Write variables
# ---------------------------------------------------------------------------

log "Writing variables.nix..."

set_var username "$USERNAME"
set_var hostname "$HOSTNAME"
set_var timezone "$TIMEZONE"
set_var gpu "$GPU"

if [ "$BOOT" = "uefi" ]; then
    set_var bootloader "systemd-boot"
else
    set_var bootloader "grub"
    set_var grubDevice "$DISK"
fi

# ---------------------------------------------------------------------------
# Hardware configuration
# ---------------------------------------------------------------------------

HARDWARE_CONFIG="hosts/nixos/hardware-configuration.nix"

if [ -f "$HARDWARE_CONFIG" ]; then
    BACKUP="/tmp/hardware-configuration.nix.bak"

    log "Backing up existing hardware configuration to $BACKUP"
    cp "$HARDWARE_CONFIG" "$BACKUP"
fi

log "Generating hardware-configuration.nix for this machine..."

sudo nixos-generate-config \
    --show-hardware-config \
    > "$HARDWARE_CONFIG"

[ -s "$HARDWARE_CONFIG" ] \
    || die "Generated hardware-configuration.nix is empty."

# ---------------------------------------------------------------------------
# Validation
# ---------------------------------------------------------------------------

log "Checking flake..."

if ! nix flake check --no-build --flake "$DEST"; then
    die "flake check failed. The system was NOT switched."
fi

# ---------------------------------------------------------------------------
# GPU warning
# ---------------------------------------------------------------------------

case "$GPU" in
    nvidia)
        log "GPU selected: NVIDIA"
        ;;

    amd)
        log "GPU selected: AMD"
        ;;

    intel)
        log "GPU selected: Intel"
        ;;
esac

# ---------------------------------------------------------------------------
# Rebuild
# ---------------------------------------------------------------------------

if [ "$SWITCH" -eq 1 ]; then
    log "Switching to the new system..."
    log "This may take a while on the first build."

    sudo nixos-rebuild switch \
        --flake "$DEST#$HOSTNAME"

    log "Installation complete."
    log "A reboot is recommended."
else
    log "Skipping nixos-rebuild switch (--no-switch)."
    log "When ready, run:"
    log "  sudo nixos-rebuild switch --flake \"$DEST#$HOSTNAME\""
fi
```
