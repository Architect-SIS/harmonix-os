# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Performance Tuning
# ═══════════════════════════════════════════════════════════════
# Maxed-out settings for AMD Ryzen 7 5800X3D + RX 6750 XT.
# Generated via NixOS Configurator principles.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

{
  # ─── CPU Governor: Full Performance ─────────────────────────
  powerManagement.cpuFreqGovernor = "performance";

  # ─── ZRAM Swap (compress RAM instead of hitting disk) ───────
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;  # Use up to 50% of 32GB as compressed swap
  };

  # ─── SSD Health: Periodic TRIM ──────────────────────────────
  services.fstrim = {
    enable = true;
    interval = "weekly";
  };

  # ─── Kernel Tuning ─────────────────────────────────────────
  boot.kernel.sysctl = {
    # Required for ROCm, Steam, and large-memory workloads
    "vm.max_map_count" = 1048576;

    # Reduce swappiness — prefer keeping things in RAM (32GB)
    "vm.swappiness" = 10;

    # Network performance (for agent comms, API calls)
    "net.core.rmem_max" = 16777216;
    "net.core.wmem_max" = 16777216;
    "net.ipv4.tcp_fastopen" = 3;

    # File watcher limit (IDEs, build tools, HyprPanel)
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 1024;
  };

  # ─── AMD GPU Performance Variables ──────────────────────────
  environment.variables = {

    # Enable Graphics Pipeline Library — faster shader compilation
    RADV_PERFTEST = "gpl";

    # ROCm: Override GFX version for 6750 XT (Navi 22 = gfx1030)
    HSA_OVERRIDE_GFX_VERSION = "10.3.0";

    # Disable Vulkan overlay (reduces compositor overhead)
    VK_LOADER_DISABLE_INST_EXT_FILTER = "1";
  };

  # ─── Additional GPU Packages ────────────────────────────────

  # ─── Gamemode (on-demand performance boost) ─────────────────
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
        softrealtime = "auto";
      };
      gpu = {
        apply_gpu_optimisations = "accept-responsibility";
        gpu_device = 0;
      };
    };
  };

  # ─── I/O Scheduler (optimal for NVMe/SSD) ──────────────────
  services.udev.extraRules = ''
    # Set none/noop scheduler for NVMe drives
    ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/scheduler}="none"
    # Set mq-deadline for SATA SSDs
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
  '';

  # ─── System Packages: Performance Monitoring ────────────────
  environment.systemPackages = with pkgs; [
    nvtopPackages.amd   # GPU monitoring (AMD-specific)
    lact                # AMD GPU fan control & monitoring
    gamemode            # On-demand performance mode
    mangohud            # Vulkan/OpenGL overlay HUD
    vulkan-tools        # vulkaninfo, vkcube
    mesa-demos         # glxinfo, glmark2
    libva-utils         # vainfo — VA-API decode info
  ];
}
