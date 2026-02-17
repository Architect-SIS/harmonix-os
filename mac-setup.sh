#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Mac Setup Script
# ═══════════════════════════════════════════════════════════════
# Run this on your Mac Mini to:
#   1. Push the repo to GitHub
#   2. Copy the repo to a USB stick for the rig
#
# Usage:
#   chmod +x mac-setup.sh
#   ./mac-setup.sh
# ═══════════════════════════════════════════════════════════════

set -euo pipefail

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BOLD}  Harmonix OS — Mac Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""

# ─── Step 1: Init Git ──────────────────────────────────────────
if [[ ! -d ".git" ]]; then
  echo -e "${YELLOW}Initializing git repo...${NC}"
  git init
  git add -A
  git commit -m "Initial commit: Harmonix OS flake"
  echo -e "${GREEN}✓ Git repo initialized${NC}"
else
  echo -e "${GREEN}✓ Git repo already exists${NC}"
  git add -A
  git diff --cached --quiet || git commit -m "Update: Harmonix OS flake"
fi

# ─── Step 2: Push to GitHub ────────────────────────────────────
echo ""
echo -e "${YELLOW}Setting up GitHub remote...${NC}"
echo "  Make sure you've created the repo at:"
echo "  https://github.com/Architect-SIS/harmonix-os"
echo ""

git remote remove origin 2>/dev/null || true
git remote add origin https://github.com/Architect-SIS/harmonix-os.git

echo -n "Push to GitHub now? [y/N]: "
read -r REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  git branch -M main
  git push -u origin main
  echo -e "${GREEN}✓ Pushed to GitHub${NC}"
else
  echo "  Skipped. Push manually with: git push -u origin main"
fi

# ─── Step 3: Copy to USB ──────────────────────────────────────
echo ""
echo "  Plug in a USB stick for the rig, then press Enter..."
read -r

echo "  Available volumes:"
ls /Volumes/ 2>/dev/null || echo "  (none found)"
echo ""
echo -n "  Enter USB volume name (e.g., UNTITLED): "
read -r USB_VOL

USB_PATH="/Volumes/$USB_VOL"
if [[ ! -d "$USB_PATH" ]]; then
  echo "  Volume not found: $USB_PATH"
  exit 1
fi

echo -e "${YELLOW}Copying harmonix-os to $USB_PATH...${NC}"
rm -rf "$USB_PATH/harmonix-os" 2>/dev/null || true
cp -r "$SCRIPT_DIR" "$USB_PATH/harmonix-os"

# Remove .git from USB copy to save space (git init happens on rig)
rm -rf "$USB_PATH/harmonix-os/.git"

echo -e "${GREEN}✓ Copied to USB${NC}"
echo ""
echo -e "${BOLD}Next steps:${NC}"
echo "  1. Also flash the NixOS minimal ISO to another USB"
echo "     Download: https://channels.nixos.org/nixos-unstable/latest-nixos-minimal-x86_64-linux.iso"
echo "  2. Plug both USBs into the rig"
echo "  3. Boot from the NixOS USB"
echo "  4. Run: sudo ./bootstrap.sh"
echo ""
