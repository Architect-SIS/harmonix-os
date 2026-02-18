# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Builder Mode (NixOS Module)
# ═══════════════════════════════════════════════════════════════
# Provides the `harmonix-builder` CLI and systemd timer
# for automated build pipeline execution.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

let
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    httpx
  ]);

  builderSrc = ../builder;

  harmonix-builder = pkgs.writeShellScriptBin "harmonix-builder" ''
    export PYTHONPATH="${builderSrc}/..":$PYTHONPATH
    exec ${pythonEnv}/bin/python -m builder.cli "$@"
  '';
in
{
  # ─── CLI Available System-Wide ────────────────────────────────
  environment.systemPackages = [ harmonix-builder ];

  # ─── Persistent Build State ───────────────────────────────────
  systemd.tmpfiles.rules = [
    "d /persist/home/architect/harmonix/builder 0755 architect users -"
    "d /persist/home/architect/harmonix/products 0755 architect users -"
    "d /persist/home/architect/harmonix/agents/knowledge/build_learnings 0755 architect users -"
  ];

  # Persistence handled in security.nix (consolidated)
}
