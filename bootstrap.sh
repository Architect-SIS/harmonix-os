#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Bootstrap Install Script
# ═══════════════════════════════════════════════════════════════
# Run this from the NixOS live USB after booting.
# It handles EVERYTHING: partitioning, formatting, mounting,
# git init, password setup, and nixos-install.
#
# Usage:
#   chmod +x bootstrap.sh
#   sudo ./bootstrap.sh
#
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

# ─── Colors ─────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

banner() {
  echo ""
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${PURPLE}  Harmonix OS — Bootstrap Installer${NC}"
  echo -e "${BLUE}═══════════════════════════════════════════════════${NC}"
  echo ""
}

step() {
  echo ""
  echo -e "${CYAN}━━━ STEP $1: $2 ━━━${NC}"
  echo ""
}

ok() {
  echo -e "  ${GREEN}✓${NC} $1"
}

warn() {
  echo -e "  ${YELLOW}⚠${NC} $1"
}

fail() {
  echo -e "  ${RED}✗${NC} $1"
  exit 1
}

ask() {
  echo -e -n "  ${BOLD}$1${NC} " >&2
  read -r REPLY
  echo "$REPLY"
}

confirm() {
  echo -e -n "  ${YELLOW}$1 [y/N]:${NC} "
  read -r REPLY
  [[ "$REPLY" =~ ^[Yy]$ ]]
}

# ─── Pre-flight Checks ─────────────────────────────────────────
banner

if [[ $EUID -ne 0 ]]; then
  fail "This script must be run as root (sudo ./bootstrap.sh)"
fi

# Check we're on NixOS live USB
if ! command -v nixos-install &>/dev/null; then
  fail "nixos-install not found. Are you booted into the NixOS live USB?"
fi

ok "Running as root on NixOS live environment"

# ─── Check Internet ────────────────────────────────────────────
step "0" "Checking internet connectivity"

if ping -c 2 -W 3 nixos.org &>/dev/null; then
  ok "Internet is working"
else
  warn "No internet detected. Trying to connect..."
  if command -v nmcli &>/dev/null; then
    echo "  Available WiFi networks:"
    nmcli dev wifi list 2>/dev/null || true
    echo ""
    WIFI_SSID=$(ask "Enter WiFi SSID (or press Enter to skip if using ethernet):")
    if [[ -n "$WIFI_SSID" ]]; then
      WIFI_PASS=$(ask "Enter WiFi password:")
      nmcli dev wifi connect "$WIFI_SSID" password "$WIFI_PASS" || warn "WiFi connection failed"
    fi
  fi
  
  if ! ping -c 2 -W 5 nixos.org &>/dev/null; then
    fail "Still no internet. Connect ethernet or fix WiFi and try again."
  fi
  ok "Internet is now working"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 1: SELECT TARGET DRIVE
# ═══════════════════════════════════════════════════════════════
step "1" "Select target drive"

echo "  Available drives:"
echo ""
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk | while read -r line; do
  echo "    $line"
done
echo ""

TARGET_DRIVE=$(ask "Enter the drive name for NixOS (e.g., nvme0n1 or sda):")
TARGET_DRIVE="/dev/$TARGET_DRIVE"

if [[ ! -b "$TARGET_DRIVE" ]]; then
  fail "Drive $TARGET_DRIVE does not exist"
fi

echo ""
echo -e "  ${RED}${BOLD}WARNING: This will DESTROY ALL DATA on $TARGET_DRIVE${NC}"
lsblk "$TARGET_DRIVE"
echo ""
if ! confirm "Are you ABSOLUTELY SURE you want to wipe $TARGET_DRIVE?"; then
  echo "  Aborted."
  exit 0
fi
if ! confirm "FINAL CONFIRMATION — Type y to destroy all data on $TARGET_DRIVE:"; then
  echo "  Aborted."
  exit 0
fi

# Detect partition naming convention (nvme uses p1, sata uses 1)
if [[ "$TARGET_DRIVE" == *"nvme"* ]]; then
  PART_PREFIX="${TARGET_DRIVE}p"
else
  PART_PREFIX="${TARGET_DRIVE}"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 2: PARTITION THE DRIVE
# ═══════════════════════════════════════════════════════════════
step "2" "Partitioning $TARGET_DRIVE"

# Unmount anything on this drive
umount -R /mnt 2>/dev/null || true
swapoff --all 2>/dev/null || true

parted "$TARGET_DRIVE" -- mklabel gpt
ok "Created GPT partition table"

parted "$TARGET_DRIVE" -- mkpart ESP fat32 1MB 513MB
parted "$TARGET_DRIVE" -- set 1 esp on
ok "Created EFI partition (512MB)"

parted "$TARGET_DRIVE" -- mkpart primary 513MB 100%
ok "Created main partition (rest of drive)"

# Wait for kernel to pick up new partitions
sleep 2
partprobe "$TARGET_DRIVE" 2>/dev/null || true
sleep 1

# ═══════════════════════════════════════════════════════════════
# STEP 3: FORMAT AND LABEL
# ═══════════════════════════════════════════════════════════════
step "3" "Formatting and labeling partitions"

mkfs.fat -F 32 -n BOOT "${PART_PREFIX}1"
ok "Formatted EFI as FAT32 (label: BOOT)"

mkfs.btrfs -f -L HARMONIX "${PART_PREFIX}2"
ok "Formatted main partition as btrfs (label: HARMONIX)"

# ═══════════════════════════════════════════════════════════════
# STEP 4: CREATE BTRFS SUBVOLUMES
# ═══════════════════════════════════════════════════════════════
step "4" "Creating btrfs subvolumes"

mount "${PART_PREFIX}2" /mnt
btrfs subvolume create /mnt/persist
ok "Created subvolume: persist"
btrfs subvolume create /mnt/nix
ok "Created subvolume: nix"
umount /mnt

# ═══════════════════════════════════════════════════════════════
# STEP 5: MOUNT EVERYTHING
# ═══════════════════════════════════════════════════════════════
step "5" "Mounting filesystem"

# Root = tmpfs (ephemeral)
mount -t tmpfs -o size=8G,mode=755 none /mnt
ok "Mounted / as tmpfs (8GB, ephemeral)"

mkdir -p /mnt/{boot,nix,persist}

mount -o subvol=nix,compress=zstd,noatime "${PART_PREFIX}2" /mnt/nix
ok "Mounted /nix (btrfs subvol)"

mount -o subvol=persist,compress=zstd,noatime "${PART_PREFIX}2" /mnt/persist
ok "Mounted /persist (btrfs subvol)"

mount "${PART_PREFIX}1" /mnt/boot
ok "Mounted /boot (EFI)"

# ═══════════════════════════════════════════════════════════════
# STEP 6: CREATE PERSIST STRUCTURE
# ═══════════════════════════════════════════════════════════════
step "6" "Creating persistent directory structure"

mkdir -p /mnt/persist/home/architect/.config/sops/age
mkdir -p /mnt/persist/home/architect/harmonix/{agents/{profiles,instruments,knowledge,memory,searxng},builder,products}
mkdir -p /mnt/persist/etc/ssh
mkdir -p /mnt/persist/etc/NetworkManager/system-connections
mkdir -p /mnt/persist/var/lib/{nixos,systemd,tailscale,containers/storage}
mkdir -p /mnt/persist/var/log

ok "Created all persistent directories"

# ═══════════════════════════════════════════════════════════════
# STEP 7: SET ARCHITECT PASSWORD
# ═══════════════════════════════════════════════════════════════
step "7" "Set password for 'architect' user"

echo "  Choose a password for the 'architect' user."
echo "  (This is what you'll use to log in after install.)"
echo ""

while true; do
  HASH=$(mkpasswd -m sha-512 2>/dev/null || mkpasswd -m sha512crypt 2>/dev/null || true)
  if [[ -n "$HASH" ]]; then
    break
  fi
  # Fallback: install mkpasswd
  nix-env -iA nixos.mkpasswd 2>/dev/null || true
  HASH=$(mkpasswd -m sha-512)
  break
done

if [[ -z "$HASH" ]]; then
  fail "Could not generate password hash. Install mkpasswd and try again."
fi

ok "Password hash generated"

# ═══════════════════════════════════════════════════════════════
# STEP 8: FIND AND COPY FLAKE
# ═══════════════════════════════════════════════════════════════
step "8" "Locating Harmonix OS flake"

FLAKE_DIR=""

# Check if bootstrap.sh is inside the harmonix-os directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/flake.nix" ]]; then
  FLAKE_DIR="$SCRIPT_DIR"
  ok "Found flake in script directory: $FLAKE_DIR"
fi

# Check USB drives if not found locally
if [[ -z "$FLAKE_DIR" ]]; then
  echo "  Searching USB drives for harmonix-os flake..."
  for dev in /dev/sd?1 /dev/sd?2; do
    [[ -b "$dev" ]] || continue
    TMPUSB=$(mktemp -d)
    if mount "$dev" "$TMPUSB" 2>/dev/null; then
      if [[ -f "$TMPUSB/harmonix-os/flake.nix" ]]; then
        FLAKE_DIR="$TMPUSB/harmonix-os"
        ok "Found flake on USB: $dev"
        break
      elif [[ -f "$TMPUSB/flake.nix" ]]; then
        FLAKE_DIR="$TMPUSB"
        ok "Found flake on USB: $dev"
        break
      fi
      umount "$TMPUSB" 2>/dev/null
    fi
    rmdir "$TMPUSB" 2>/dev/null || true
  done
fi

if [[ -z "$FLAKE_DIR" ]]; then
  fail "Could not find harmonix-os flake. Make sure the USB with the flake is plugged in, or run this script from inside the harmonix-os directory."
fi

# Copy to persist
DEST="/mnt/persist/home/architect/harmonix-os"
if [[ "$FLAKE_DIR" != "$DEST" ]]; then
  cp -r "$FLAKE_DIR" "$DEST"
  ok "Copied flake to $DEST"
else
  ok "Flake already in place"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 9: INJECT PASSWORD HASH INTO USERS.NIX
# ═══════════════════════════════════════════════════════════════
step "9" "Injecting password hash"

USERS_NIX="$DEST/system/users.nix"
if [[ -f "$USERS_NIX" ]]; then
  # Escape the hash for sed (contains $ and / characters)
  ESCAPED_HASH=$(printf '%s\n' "$HASH" | sed 's/[&/\]/\\&/g')
  sed -i "s|initialHashedPassword = \".*\"|initialHashedPassword = \"$ESCAPED_HASH\"|" "$USERS_NIX"
  ok "Password hash injected into users.nix"
else
  fail "users.nix not found at $USERS_NIX"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 10: MERGE HARDWARE CONFIG
# ═══════════════════════════════════════════════════════════════
step "10" "Generating and merging hardware configuration"

nixos-generate-config --root /mnt 2>/dev/null || true

if [[ -f /mnt/etc/nixos/hardware-configuration.nix ]]; then
  echo ""
  echo -e "  ${YELLOW}Auto-detected hardware config:${NC}"
  echo "  ─────────────────────────────"
  grep -E "(availableKernelModules|kernelModules|fileSystems)" /mnt/etc/nixos/hardware-configuration.nix 2>/dev/null | head -20
  echo ""
  
  # Extract any extra kernel modules we might have missed
  AUTO_MODULES=$(grep "availableKernelModules" /mnt/etc/nixos/hardware-configuration.nix 2>/dev/null | head -1 || true)
  if [[ -n "$AUTO_MODULES" ]]; then
    ok "Hardware auto-detected. Review /mnt/etc/nixos/hardware-configuration.nix if install fails."
  fi
fi

ok "Using custom hardware-configuration.nix (by-label references)"

# ═══════════════════════════════════════════════════════════════
# STEP 11: INITIALIZE GIT REPO (CRITICAL FOR FLAKES)
# ═══════════════════════════════════════════════════════════════
step "11" "Initializing git repository"

cd "$DEST"

# Ensure git is available
if ! command -v git &>/dev/null; then
  nix-env -iA nixos.git 2>/dev/null || true
fi

# Fix ownership so git/nix can operate as root on live USB
chown -R root:root "$DEST"

# Use env vars for git identity (no writable config file needed on live USB)
export GIT_AUTHOR_NAME="Architect-SIS"
export GIT_AUTHOR_EMAIL="fabricatedkc@gmail.com"
export GIT_COMMITTER_NAME="Architect-SIS"
export GIT_COMMITTER_EMAIL="fabricatedkc@gmail.com"

# If already a git repo (re-run), reset it
rm -rf "$DEST/.git"

git init
git add -A
git -c safe.directory="$DEST" commit -m "Initial commit: Harmonix OS flake"
ok "Git repo initialized and ALL files staged + committed"
ok "This is CRITICAL — Nix flakes only see git-tracked files"

# Mark safe for nix to read
git config --global --add safe.directory "$DEST" 2>/dev/null || true

# Set up remote (won't push yet — no auth on live USB)
git remote add origin https://github.com/Architect-SIS/harmonix-os.git 2>/dev/null || true
ok "Remote set to github.com/Architect-SIS/harmonix-os"

# ═══════════════════════════════════════════════════════════════
# STEP 12: GENERATE MACHINE-ID
# ═══════════════════════════════════════════════════════════════
step "12" "Generating machine identity"

# machine-id is needed for systemd
systemd-machine-id-setup --root=/mnt 2>/dev/null || true
if [[ -f /mnt/etc/machine-id ]]; then
  cp /mnt/etc/machine-id /mnt/persist/etc/machine-id
  ok "Machine ID generated and persisted"
fi

# Generate SSH host key (skip if already exists from previous run)
if [[ ! -f /mnt/persist/etc/ssh/ssh_host_ed25519_key ]]; then
  ssh-keygen -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -q
  ok "SSH host key generated"
else
  ok "SSH host key already exists (previous run)"
fi

# ═══════════════════════════════════════════════════════════════
# STEP 13: INSTALL NIXOS
# ═══════════════════════════════════════════════════════════════
step "13" "Installing NixOS"

echo ""
echo -e "  ${BOLD}${GREEN}Everything is ready. Starting nixos-install...${NC}"
echo ""
echo "  This will:"
echo "    1. Evaluate the entire flake"
echo "    2. Download packages from cache.nixos.org"
echo "    3. Build Hyprland, Podman, ag-ui, builder CLI"
echo "    4. Install systemd-boot"
echo "    5. Set up ephemeral root + impermanence"
echo ""
echo -e "  ${YELLOW}This takes 10-30 minutes depending on internet speed.${NC}"
echo ""

if ! confirm "Ready to install?"; then
  echo ""
  echo "  You can install manually with:"
  echo "    sudo nixos-install --flake $DEST#harmonix --no-root-password"
  exit 0
fi

echo ""
nixos-install --flake "$DEST#harmonix" --no-root-password 2>&1 | tee /tmp/harmonix-install.log

INSTALL_EXIT=${PIPESTATUS[0]}

if [[ $INSTALL_EXIT -eq 0 ]]; then
  echo ""
  echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${GREEN}  HARMONIX OS INSTALLED SUCCESSFULLY${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════════════${NC}"
  echo ""
  echo "  Next steps:"
  echo "    1. Remove the USB stick(s)"
  echo "    2. Reboot:  sudo reboot"
  echo "    3. Log in as 'architect' with the password you set"
  echo "    4. Open terminal: Super + Return"
  echo "    5. Connect Tailscale: sudo tailscale up"
  echo "    6. Push to GitHub:"
  echo "       cd ~/harmonix-os"
  echo "       git remote set-url origin git@github.com:Architect-SIS/harmonix-os.git"
  echo "       git push -u origin main"
  echo ""
  echo "  Post-install (optional):"
  echo "    - Set up SOPS age key for encrypted secrets"
  echo "    - Start AgentZero: sudo podman start agent-zero"
  echo "    - Start SearXNG:   sudo podman start searxng"
  echo ""
else
  echo ""
  echo -e "${RED}═══════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${RED}  INSTALL FAILED${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════${NC}"
  echo ""
  echo "  Install log saved to: /tmp/harmonix-install.log"
  echo "  Last 30 lines of errors:"
  echo ""
  tail -30 /tmp/harmonix-install.log | grep -i "error\|fail\|trace" || tail -30 /tmp/harmonix-install.log
  echo ""
  echo "  Common fixes:"
  echo "    - 'gitTracked' error → cd $DEST && git add -A && git commit -m fix"
  echo "    - Package not found → nix flake update $DEST"
  echo "    - Hardware mismatch → check system/hardware-configuration.nix"
  echo ""
fi
