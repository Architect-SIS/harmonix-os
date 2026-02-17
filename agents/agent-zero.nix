# ═══════════════════════════════════════════════════════════════
# Harmonix OS — AgentZero Integration (NixOS Module)
# ═══════════════════════════════════════════════════════════════
# Full AgentZero framework running inside Podman.
# Profiles, instruments, and knowledge wired in.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

let
  agentZeroSrc = inputs.agent-zero;
  harmonixAgentsDir = "/persist/home/architect/harmonix/agents";
in
{
  # ─── AgentZero Container ──────────────────────────────────────
  virtualisation.oci-containers.containers.agent-zero = {
    image = "frdel/agent-zero:latest";
    autoStart = false;  # Start manually after first boot: podman start agent-zero

    volumes = [
      "${harmonixAgentsDir}/profiles:/app/prompts/profiles:ro"
      "${harmonixAgentsDir}/instruments:/app/instruments:rw"
      "${harmonixAgentsDir}/knowledge:/app/knowledge:ro"
      "${harmonixAgentsDir}/memory:/app/memory:rw"
      "${harmonixAgentsDir}/settings.json:/app/settings.json:ro"
    ];

    environment = {
      TOKENIZERS_PARALLELISM = "true";
    };

    # API key: set via environment file AFTER sops is configured.
    # Create /persist/home/architect/harmonix/agents/.env with:
    #   OPENROUTER_API_KEY=your_key_here
    # Then uncomment:
    # environmentFiles = [ "${harmonixAgentsDir}/.env" ];

    ports = [
      "127.0.0.1:50001:50001"
    ];

    extraOptions = [
      "--memory=8g"
      "--cpus=4"
      "--restart=unless-stopped"
    ];
  };

  # ─── SearXNG (Privacy Search for AgentZero) ──────────────────
  virtualisation.oci-containers.containers.searxng = {
    image = "searxng/searxng:latest";
    autoStart = false;  # Start manually: podman start searxng

    ports = [
      "127.0.0.1:8888:8080"
    ];

    volumes = [
      "${harmonixAgentsDir}/searxng:/etc/searxng:rw"
    ];

    extraOptions = [
      "--memory=1g"
      "--cpus=1"
      "--restart=unless-stopped"
    ];
  };

  # ─── Ensure directories exist ─────────────────────────────────
  systemd.tmpfiles.rules = [
    "d ${harmonixAgentsDir}/profiles 0755 architect users -"
    "d ${harmonixAgentsDir}/instruments 0755 architect users -"
    "d ${harmonixAgentsDir}/knowledge 0755 architect users -"
    "d ${harmonixAgentsDir}/memory 0755 architect users -"
    "d ${harmonixAgentsDir}/searxng 0755 architect users -"
  ];

  # Persistence handled in security.nix (consolidated)
}
