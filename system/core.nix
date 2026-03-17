# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Core System Configuration
# ═══════════════════════════════════════════════════════════════
# Minimal, hardened, sovereign.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

{
  # Allow unfree packages (claude-code)
  nixpkgs.config.allowUnfree = true;
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

    # Electron / native module build tools
    gcc
    gnumake
    pkg-config
    libsecret
    
    # AppImage support (1Code terminal)
    # AppImage support (1Code terminal)
    appimage-run

    # Bun runtime (1Code build)
    bun

    # Claude Code
    claude-code

    # System
    pciutils
    usbutils
    lsof
  ];

  # ─── Dynamic Linking (FHS compat) ──────────────────────────────
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      glib
      nss
      nspr
      dbus
      atk
      cups
      libdrm
      gtk3
      pango
      cairo
      xorg.libX11
      xorg.libXcomposite
      xorg.libXdamage
      xorg.libXext
      xorg.libXfixes
      xorg.libXrandr
      xorg.libxcb
      mesa
      expat
      alsa-lib
      at-spi2-atk
      at-spi2-core
      libxkbcommon
      vulkan-loader
      mesa.drivers
      libgbm
      libGL
      libglvnd
    ];
  };

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
      noto-fonts-color-emoji
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
    xserver.enable = true;  # Wayland only, no X11

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

  # ─── Hardware (AMD Radeon RX 6750 XT / Navi 22) ─────────────
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;  # 32-bit Vulkan/GL support
    };
    amdgpu = {
      initrd.enable = true;  # Load amdgpu early in boot
    };
  };
}





