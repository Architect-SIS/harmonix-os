# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Container Runtime
# ═══════════════════════════════════════════════════════════════
# Podman (rootless, daemonless) for AgentZero sandboxing.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

{
  # ─── Podman (Preferred over Docker) ───────────────────────────
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    defaultNetwork.settings.dns_enabled = true;

    autoPrune = {
      enable = true;
      dates = "weekly";
    };
  };

  # ─── OCI Containers (Declarative) ────────────────────────────
  virtualisation.oci-containers = {
    backend = "podman";
    containers = { };  # Populated by agent-zero.nix
  };

  # ─── User Namespace Support ───────────────────────────────────
  security.unprivilegedUsernsClone = true;

  # Storage driver
  virtualisation.containers.storage.settings = {
    storage = {
      driver = "overlay";
      graphroot = "/persist/var/lib/containers/storage";
      runroot = "/run/containers/storage";
    };
  };
}
