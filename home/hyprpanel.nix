# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Hyprpanel Configuration
# ═══════════════════════════════════════════════════════════════
# Themeable panel — agent status, system metrics, notifications.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  home.packages = [
    inputs.hyprpanel.packages.${pkgs.system}.default
  ];

  xdg.configFile."hyprpanel/config.json".text = builtins.toJSON {
    theme = {
      name = "harmonix-dark";
      bar = {
        background = "#0A0A0B";
        foreground = "#F0F0F2";
        accent = "#0066FF";
        accent_secondary = "#7C3AED";
        border_color = "#1A1A1E";
        border_radius = "12px";
      };
      notification = {
        background = "#1A1A1E";
        foreground = "#F0F0F2";
        border = "#0066FF";
      };
    };
    layout = {
      left = [ "workspaces" ];
      center = [ "clock" ];
      right = [ "systray" "network" "bluetooth" "volume" "battery" "notifications" ];
    };
    modules = {
      clock = {
        format = "%H:%M  |  %a %b %d";
        font_family = "Inter";
        font_size = 13;
      };
      workspaces = {
        numbered = true;
        show_icons = false;
        count = 8;
      };
    };
  };
}
