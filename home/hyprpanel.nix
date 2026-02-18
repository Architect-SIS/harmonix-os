# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Hyprpanel Configuration
# ═══════════════════════════════════════════════════════════════
# HyprPanel is now in nixpkgs — programs.hyprpanel from home-manager.
# No flake input needed.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  programs.hyprpanel = {
    enable = true;
    # package comes from nixpkgs automatically via programs.hyprpanel

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
