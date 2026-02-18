# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Hyprpanel Configuration
# ═══════════════════════════════════════════════════════════════
# Themeable panel — agent status, system metrics, notifications.
# Uses the official programs.hyprpanel Home Manager module.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  programs.hyprpanel = {
    enable = true;
    package = inputs.hyprpanel.packages.${pkgs.system}.default;

    # HyprPanel handles notifications — mako must NOT run alongside it.
    # See home/hyprland.nix exec-once for startup config.

    settings = {
      layout = {
        "bar.layouts" = {
          "0" = {
            left   = [ "workspaces" ];
            middle = [ "clock" ];
            right  = [ "systray" "network" "volume" "notifications" ];
          };
        };
      };

      bar.workspaces = {
        show_icons = false;
        count = 8;
      };

      menus.clock.time = {
        military = true;
        hideSeconds = false;
      };

      theme.bar = {
        background = "#0A0A0B";
        transparent = false;
      };

      theme.font = {
        name = "JetBrainsMono Nerd Font";
        size = "13px";
      };
    };
  };
}
