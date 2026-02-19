#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Bootstrap v2
# ═══════════════════════════════════════════════════════════════
# Run from NixOS live USB. Wipes target drive, clones from
# GitHub, sets password, installs NixOS. One shot.
#
# Usage:
#   sudo bash bootstrap.sh
#   OR: bash <(curl -sL https://raw.githubusercontent.com/Architect-SIS/harmonix-os/main/bootstrap.sh)
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; PURPLE='\033[0;35m'; CYAN='\033[0;36m'
BOLD='\033[1m'; NC='\033[0m'

ok()      { echo -e "  ${GREEN}✓${NC} $1"; }
warn()    { echo -e "  ${YELLOW}⚠${NC} $1"; }
die()     { echo -e "\n  ${RED}✗ FATAL: $1${NC}\n"; exit 1; }
step()    { echo -e "\n${CYAN}━━━ [$1] $2 ━━━${NC}\n"; }
ask()     { printf "  %s " "$1" >&2; read -r REPLY; echo "$REPLY"; }
confirm() { printf "  ${YELLOW}%s [y/N]:${NC} " "$1"; read -r R; [[ "$R" =~ ^[Yy]$ ]]; }

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}${PURPLE}    Harmonix OS — Bootstrap Installer v2${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}"
echo ""

[[ $EUID -ne 0 ]] && die "Must run as root: sudo bash bootstrap.sh"
command -v nixos-install &>/dev/null || die "Not on NixOS live USB"

# ─── Internet ────────────────────────────────────────────────
step "0" "Internet"
ping -c 1 -W 5 github.com &>/dev/null && ok "Online" || die "No internet. Connect ethernet and retry."

# ─── Select drive ────────────────────────────────────────────
step "1" "Select drive to WIPE"
echo "  Drives available:"
lsblk -d -o NAME,SIZE,MODEL,TYPE | grep disk | sed 's/^/    /'
echo ""
TARGET=$(ask "Drive to WIPE (e.g. sda, nvme0n1):")
TARGET="/dev/$TARGET"
[[ -b "$TARGET" ]] || die "$TARGET is not a block device"

echo ""
echo -e "  ${RED}${BOLD}ALL DATA ON $TARGET WILL BE DESTROYED${NC}"
lsblk "$TARGET" | sed 's/^/  /'
echo ""
confirm "Wipe $TARGET?" || { echo "  Aborted."; exit 0; }
confirm "FINAL CONFIRM — destroy $TARGET?" || { echo "  Aborted."; exit 0; }

[[ "$TARGET" == *nvme* ]] && PART="${TARGET}p" || PART="${TARGET}"

# ─── Password FIRST ──────────────────────────────────────────
step "2" "Set login password for 'architect'"
echo "  This becomes your login password. You can change it with 'passwd' after boot."
echo ""
HASH=$(mkpasswd -m sha-512)
[[ -n "$HASH" ]] || die "Failed to generate password hash"
ok "Password hash ready"

# ─── Partition ───────────────────────────────────────────────
step "3" "Partitioning $TARGET"
umount -R /mnt 2>/dev/null || true
swapoff --all 2>/dev/null || true

parted -s "$TARGET" -- mklabel gpt
parted -s "$TARGET" -- mkpart ESP fat32 1MB 513MB
parted -s "$TARGET" -- set 1 esp on
parted -s "$TARGET" -- mkpart primary 513MB 100%
sleep 2; partprobe "$TARGET" 2>/dev/null || true; sleep 1
ok "GPT: 512MB EFI + remaining main"

# ─── Format ──────────────────────────────────────────────────
step "4" "Formatting"
mkfs.fat -F 32 -n BOOT "${PART}1"
ok "EFI: FAT32 (label BOOT)"
mkfs.btrfs -f -L HARMONIX "${PART}2"
ok "Main: btrfs (label HARMONIX)"

# ─── Btrfs subvolumes ────────────────────────────────────────
step "5" "Btrfs subvolumes"
mount "${PART}2" /mnt
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
umount /mnt
ok "Subvolumes: nix, persist"

# ─── Mount ───────────────────────────────────────────────────
step "6" "Mounting"
mount -t tmpfs -o size=8G,mode=755 none /mnt
mkdir -p /mnt/{boot,nix,persist}
mount -o subvol=nix,compress=zstd,noatime "${PART}2" /mnt/nix
mount -o subvol=persist,compress=zstd,noatime "${PART}2" /mnt/persist
mount "${PART}1" /mnt/boot
ok "/ tmpfs | /nix | /persist | /boot mounted"

# ─── Persist structure ───────────────────────────────────────
step "7" "Persistent directories"
mkdir -p /mnt/persist/etc/ssh
mkdir -p /mnt/persist/etc/NetworkManager/system-connections
mkdir -p /mnt/persist/var/log
mkdir -p /mnt/persist/var/lib/nixos
mkdir -p /mnt/persist/var/lib/systemd
mkdir -p /mnt/persist/var/lib/tailscale
mkdir -p /mnt/persist/var/lib/containers/storage
mkdir -p /mnt/persist/home/architect/.config/sops/age
mkdir -p /mnt/persist/home/architect/.ssh
mkdir -p /mnt/persist/home/architect/harmonix/agents/profiles
mkdir -p /mnt/persist/home/architect/harmonix/agents/instruments
mkdir -p /mnt/persist/home/architect/harmonix/agents/knowledge
mkdir -p /mnt/persist/home/architect/harmonix/agents/memory
mkdir -p /mnt/persist/home/architect/harmonix/agents/searxng
mkdir -p /mnt/persist/home/architect/harmonix/builder
mkdir -p /mnt/persist/home/architect/harmonix/products
ok "Persist structure ready"

# ─── Clone from GitHub ───────────────────────────────────────
step "8" "Cloning harmonix-os from GitHub"
DEST="/mnt/persist/home/architect/harmonix-os"
git clone https://github.com/Architect-SIS/harmonix-os.git "$DEST"
ok "Cloned to $DEST"

# ─── Inject password ─────────────────────────────────────────
step "9" "Injecting password into users.nix"
USERS="$DEST/system/users.nix"

# Use python to safely substitute — avoids all shell escaping issues with $ in hashes
python3 - "$USERS" "$HASH" << 'PYEOF'
import sys, re
path, new_hash = sys.argv[1], sys.argv[2]
with open(path) as f:
    content = f.read()
# Replace hashedPassword for architect (not root)
content = re.sub(
    r'(hashedPassword\s*=\s*")[^"]*(";\s*)',
    lambda m: m.group(0).replace(m.group(0), f'hashedPassword = "{new_hash}";', 1),
    content,
    count=1
)
with open(path, 'w') as f:
    f.write(content)
print("  Hash injected")
PYEOF

ok "Password hash set in users.nix"

# ─── Git commit (REQUIRED for nix flakes) ────────────────────
step "10" "Git commit (nix flakes only see tracked files)"
cd "$DEST"
export GIT_AUTHOR_NAME="Architect-SIS"
export GIT_AUTHOR_EMAIL="fabricatedkc@gmail.com"
export GIT_COMMITTER_NAME="Architect-SIS"
export GIT_COMMITTER_EMAIL="fabricatedkc@gmail.com"
git config --global --add safe.directory "$DEST"
git add -A
git commit -m "bootstrap: inject password hash"
ok "Committed — nix flake will see all files"

# ─── Machine identity ────────────────────────────────────────
step "11" "Machine identity"
systemd-machine-id-setup --root=/mnt 2>/dev/null || true
[[ -f /mnt/etc/machine-id ]] && cp /mnt/etc/machine-id /mnt/persist/etc/machine-id || true
ssh-keygen -t ed25519 -f /mnt/persist/etc/ssh/ssh_host_ed25519_key -N "" -q
ok "machine-id + SSH host key ready"

# ─── Install ─────────────────────────────────────────────────
step "12" "Installing NixOS"
echo ""
echo -e "  ${BOLD}Running: nixos-install --flake $DEST#harmonix${NC}"
echo -e "  ${YELLOW}Takes 10-30 minutes. Do not interrupt.${NC}"
echo ""

nixos-install --flake "$DEST#harmonix" --no-root-password 2>&1 | tee /tmp/harmonix-install.log
EXIT=${PIPESTATUS[0]}

echo ""
if [[ $EXIT -eq 0 ]]; then
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${GREEN}  HARMONIX OS INSTALLED — ΣΔ → 0${NC}"
  echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
  echo ""
  echo "  1. Remove USB"
  echo "  2. sudo reboot"
  echo "  3. Login: architect / <password you just set>"
  echo "  4. Super+Return to open terminal"
  echo "  5. Run: passwd   (to change password)"
  echo "  6. Run: sudo tailscale up"
  echo ""
else
  echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
  echo -e "${BOLD}${RED}  INSTALL FAILED${NC}"
  echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
  echo ""
  echo "  Errors:"
  grep -i "error\|fail" /tmp/harmonix-install.log | tail -20 | sed 's/^/  /' || true
  echo ""
  echo "  Full log: /tmp/harmonix-install.log"
fi
