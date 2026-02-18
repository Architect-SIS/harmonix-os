# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Core System Configuration
# ═══════════════════════════════════════════════════════════════
# Minimal, hardened, sovereign.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

{
  # ─── Boot ─────────────────────────────────────────────────────
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
      timeout = 3;
    };

    # Hardened kernel
    kernelPackages = pkgs.linuxPackages_latest;

    # Strip unnecessary kernel modules
    blacklistedKernelModules = [
      "pcspkr"       # No beeping
      "snd_pcsp"     # No PC speaker sound
    ];

    # Minimal initrd
    initrd.systemd.enable = true;
  };

  # ─── System ───────────────────────────────────────────────────
  system.stateVersion = "24.11";

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "architect" ];

      # Reproducibility
      sandbox = true;
      require-sigs = true;
    };

    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # ─── Locale & Time ────────────────────────────────────────────
  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  # ─── Core Packages (minimal) ──────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Essentials
    git
    curl
    wget
    unzip
    htop
    btop
    neovim
    ripgrep
    fd
    jq
    yq-go
    tree

    # Development
    python312
    python312Packages.pip
    python312Packages.virtualenv
    nodejs_22
    rustup

    # Nix tools
    nil             # Nix LSP
    nixfmt-rfc-style

    # System
    pciutils
    usbutils
    lsof
  ];

  # ─── Shell ────────────────────────────────────────────────────
  programs.zsh = {
    enable = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # ─── Fonts ────────────────────────────────────────────────────
  fonts = {
    packages = with pkgs; [
      inter
      jetbrains-mono
      noto-fonts
      noto-fonts-emoji
      (nerd-fonts.jetbrains-mono)
    ];
    fontconfig.defaultFonts = {
      serif = [ "Noto Serif" ];
      sansSerif = [ "Inter" ];
      monospace = [ "JetBrainsMono Nerd Font" ];
    };
  };

  # ─── Services ─────────────────────────────────────────────────
  services = {
    # Disable unnecessary services
    xserver.enable = false;  # Wayland only, no X11

    # Pipewire for audio
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # D-Bus
    dbus.enable = true;
  };

  # ─── Hardware ─────────────────────────────────────────────────
  hardware = {
    graphics.enable = true;
  };
}
