# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Networking
# ═══════════════════════════════════════════════════════════════
# Tailscale mesh. No public exposure.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

{
  # ─── Hostname ─────────────────────────────────────────────────
  networking = {
    hostName = "harmonix";
    networkmanager.enable = true;

    # DNS over TLS
    nameservers = [
      "1.1.1.1"
      "9.9.9.9"
    ];
  };

  # ─── Tailscale (Sovereign Mesh) ───────────────────────────────
  services.tailscale = {
    enable = true;
    useRoutingFeatures = "both";
    openFirewall = true;

    # First boot: authenticate manually with `sudo tailscale up`
    # After SOPS is configured, uncomment the line below:
    # authKeyFile = config.sops.secrets."tailscale/auth_key".path;
  };

  # ─── Avahi (Local Discovery) ──────────────────────────────────
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
