# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Hardware Configuration
# ═══════════════════════════════════════════════════════════════
# Target: AMD Ryzen 7 + Radeon RX 6750 XT (12GB) + 32GB DDR4
#          2-3 drives, ~3TB total
#
# NOTE: The bootstrap script will auto-merge values from
#   nixos-generate-config into this file. You can also run:
#   nixos-generate-config --root /mnt --show-hardware-config
# and manually update anything missed.
# ΣΔ → 0
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # ─── Kernel / Initrd ─────────────────────────────────────────
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
    "usbhid"
  ];

  boot.kernelModules = [ "kvm-amd" ];

  # ─── AMD GPU — AMDGPU (open-source, sovereign) ──────────────
  boot.initrd.kernelModules = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.graphics.extraPackages = with pkgs; [
    rocmPackages.clr.icd   # OpenCL for compute / AI
  ];

  # ─── CPU ──────────────────────────────────────────────────────
  hardware.cpu.amd.updateMicrocode = true;

  # ─── Filesystem Layout ────────────────────────────────────────
  # Root = tmpfs (RAM-backed, ephemeral — wiped every boot)
  # /nix = btrfs subvol on primary drive (nix store, large)
  # /persist = btrfs subvol on primary drive (persistent state)
  # /boot = EFI system partition (FAT32, 512MB)

  fileSystems."/" = {
    device = "none";
    fsType = "tmpfs";
    options = [ "defaults" "size=8G" "mode=755" ];
  };

  fileSystems."/persist" = {
    device = "/dev/disk/by-label/HARMONIX";
    fsType = "btrfs";
    options = [ "subvol=persist" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/HARMONIX";
    fsType = "btrfs";
    options = [ "subvol=nix" "compress=zstd" "noatime" ];
    neededForBoot = true;
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/BOOT";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  swapDevices = [ ];

  # ─── Networking (hardware-level) ──────────────────────────────
  networking.useDHCP = lib.mkDefault true;

  # ─── Platform ─────────────────────────────────────────────────
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
