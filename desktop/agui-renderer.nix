# ═══════════════════════════════════════════════════════════════
# Harmonix OS — ag-ui Renderer Service (NixOS Module)
# ═══════════════════════════════════════════════════════════════
# Runs the ag-ui renderer as a systemd user service.
# Receives events from AgentZero and renders them in Hyprland.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

let
  pythonEnv = pkgs.python312.withPackages (ps: with ps; [
    fastapi
    uvicorn
    httpx
    aiofiles
  ]);

  rendererSrc = ./agui_renderer;
in
{
  # ─── Systemd User Service ────────────────────────────────────
  # Runs as the architect user so it can access Hyprland IPC
  systemd.user.services.agui-renderer = {
    description = "Harmonix ag-ui Renderer";
    wantedBy = [ "hyprland-session.target" ];
    after = [ "hyprland-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pythonEnv}/bin/uvicorn desktop.agui_renderer.server:app --host 127.0.0.1 --port 3100";
      WorkingDirectory = "/persist/home/architect/harmonix-os";
      Restart = "on-failure";
      RestartSec = 5;

      # Security hardening
      NoNewPrivileges = true;
      ProtectHome = "read-only";
      ProtectSystem = "strict";
      ReadWritePaths = [ "/tmp" ];
    };

    environment = {
      PYTHONPATH = "${rendererSrc}/..";
      DISPLAY = "";
      WAYLAND_DISPLAY = "wayland-1";
      XDG_RUNTIME_DIR = "/run/user/1000";
      HYPRLAND_INSTANCE_SIGNATURE = "";
    };
  };

  # NOTE: ag-ui binds to 127.0.0.1 only — no firewall rule needed.
  # Persistence for agui data is handled in security.nix (consolidated).
}
