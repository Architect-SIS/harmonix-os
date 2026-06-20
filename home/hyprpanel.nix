# ═══════════════════════════════════════════════════════════════
# Harmonix OS — HyprPanel Configuration
# ═══════════════════════════════════════════════════════════════
# Sovereign panel — Harmonix brand, all 8 workspaces, media, agents.
# HyprPanel uses FLAT dot-notation keys in config.json.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  home.packages = [
    inputs.hyprpanel.packages.${pkgs.system}.default
  ];

  # HyprPanel config.json — flat dot-notation keys
  # These match HyprPanel's ConfigManager.updateOption(id, value)
  xdg.configFile."hyprpanel/config.json".text = builtins.toJSON {

    # ─── Bar Layout (per-monitor, monitor 0) ───────────────────
    "bar.layouts" = {
      "0" = {
        left = [ "dashboard" "workspaces" "windowtitle" ];
        middle = [ "media" ];
        right = [ "volume" "network" "bluetooth" "systray" "clock" "notifications" ];
      };
    };

    # ─── Bar Position & Behavior ───────────────────────────────
    "bar.position" = "top";
    "bar.customModuleRight" = "";
    "bar.customModuleCenter" = "";
    "bar.customModuleLeft" = "";

    # ─── Workspaces (show ALL 8, numbered, with active indicator) ─
    "bar.workspaces.workspaces" = 8;
    "bar.workspaces.show_numbered" = true;
    "bar.workspaces.showAllActive" = true;
    "bar.workspaces.numbered_active_indicator" = "underline";
    "bar.workspaces.monitorSpecific" = false;
    "bar.workspaces.spacing" = 1;

    # ─── Clock ─────────────────────────────────────────────────
    "bar.clock.format" = "%H:%M  |  %a %b %d";
    "bar.clock.showIcon" = false;
    "bar.clock.showTime" = true;
    "bar.clock.showDate" = false;

    # ─── Media ─────────────────────────────────────────────────
    "bar.media.show_active_only" = true;
    "bar.media.truncation" = true;
    "bar.media.truncation_size" = 30;
    "bar.media.show_label" = true;

    # ─── Notifications ─────────────────────────────────────────
    "notifications.position" = "top right";
    "notifications.timeout" = 5000;
    "notifications.cache_actions" = true;

    # ─── Theme: Harmonix Brand ─────────────────────────────────
    # Void Black #0A0A0B | Delta Blue #0066FF | Resonance White #F0F0F2

    # Bar theme
    "theme.bar.background" = "#0A0A0B";
    "theme.bar.transparent" = false;
    "theme.bar.floating" = false;
    "theme.bar.opacity" = 100;
    "theme.bar.outer_spacing" = "0.3em";
    "theme.bar.label_spacing" = "0.5em";
    "theme.bar.border_radius" = "0em";
    "theme.bar.margin_top" = "0em";
    "theme.bar.margin_bottom" = "0em";
    "theme.bar.margin_sides" = "0em";
    "theme.bar.padding_x" = "0.6em";
    "theme.bar.padding_y" = "0.2em";

    # Bar border
    "theme.bar.border.color" = "#0066FF";
    "theme.bar.border.location" = "bottom";
    "theme.bar.border.width" = "0.1em";

    # Font
    "theme.font.name" = "Inter";
    "theme.font.size" = "1rem";
    "theme.font.weight" = 500;

    # ─── Button Colors (per-widget theming) ────────────────────

    # Dashboard button (left corner)
    "theme.bar.buttons.dashboard.background" = "#0A0A0B";
    "theme.bar.buttons.dashboard.icon" = "#0066FF";
    "theme.bar.buttons.dashboard.hover" = "#1A1A2E";

    # Workspace buttons
    "theme.bar.buttons.workspaces.background" = "#0A0A0B";
    "theme.bar.buttons.workspaces.hover" = "#1A1A2E";
    "theme.bar.buttons.workspaces.active" = "#0066FF";
    "theme.bar.buttons.workspaces.available" = "#3A3A4E";
    "theme.bar.buttons.workspaces.occupied" = "#F0F0F2";

    # Window title
    "theme.bar.buttons.windowtitle.background" = "#0A0A0B";
    "theme.bar.buttons.windowtitle.text" = "#F0F0F2";
    "theme.bar.buttons.windowtitle.icon" = "#0066FF";
    "theme.bar.buttons.windowtitle.hover" = "#1A1A2E";

    # Clock
    "theme.bar.buttons.clock.background" = "#0A0A0B";
    "theme.bar.buttons.clock.text" = "#F0F0F2";
    "theme.bar.buttons.clock.icon" = "#0066FF";
    "theme.bar.buttons.clock.hover" = "#1A1A2E";

    # Media
    "theme.bar.buttons.media.background" = "#0A0A0B";
    "theme.bar.buttons.media.text" = "#F0F0F2";
    "theme.bar.buttons.media.icon" = "#0066FF";
    "theme.bar.buttons.media.hover" = "#1A1A2E";

    # Volume
    "theme.bar.buttons.volume.background" = "#0A0A0B";
    "theme.bar.buttons.volume.icon" = "#0066FF";
    "theme.bar.buttons.volume.text" = "#F0F0F2";
    "theme.bar.buttons.volume.hover" = "#1A1A2E";

    # Network
    "theme.bar.buttons.network.background" = "#0A0A0B";
    "theme.bar.buttons.network.icon" = "#0066FF";
    "theme.bar.buttons.network.text" = "#F0F0F2";
    "theme.bar.buttons.network.hover" = "#1A1A2E";

    # Bluetooth
    "theme.bar.buttons.bluetooth.background" = "#0A0A0B";
    "theme.bar.buttons.bluetooth.icon" = "#0066FF";
    "theme.bar.buttons.bluetooth.text" = "#F0F0F2";
    "theme.bar.buttons.bluetooth.hover" = "#1A1A2E";

    # Systray
    "theme.bar.buttons.systray.background" = "#0A0A0B";

    # Notifications
    "theme.bar.buttons.notifications.background" = "#0A0A0B";
    "theme.bar.buttons.notifications.icon" = "#0066FF";
    "theme.bar.buttons.notifications.text" = "#F0F0F2";
    "theme.bar.buttons.notifications.hover" = "#1A1A2E";
    "theme.bar.buttons.notifications.total" = "#0066FF";

    # ─── Notification popup theme ──────────────────────────────
    "theme.notification.background" = "#1A1A1E";
    "theme.notification.border" = "#0066FF";
    "theme.notification.labelColor" = "#F0F0F2";
    "theme.notification.border_radius" = "0.6em";

    # ─── OSD (on-screen display) theme ─────────────────────────
    "theme.osd.bar_color" = "#0066FF";
    "theme.osd.bar_overflow_color" = "#FF4444";
    "theme.osd.icon" = "#F0F0F2";
    "theme.osd.icon_container" = "#0A0A0B";
    "theme.osd.label" = "#F0F0F2";
    "theme.osd.bar_container" = "#1A1A1E";

    # ─── Menus theme ───────────────────────────────────────────
    "theme.bar.menus.background" = "#0A0A0B";
    "theme.bar.menus.cards" = "#1A1A1E";
    "theme.bar.menus.card_radius" = "0.6em";
    "theme.bar.menus.label" = "#F0F0F2";
    "theme.bar.menus.text" = "#D0D0D2";
    "theme.bar.menus.dimtext" = "#6A6A7E";
    "theme.bar.menus.feinttext" = "#3A3A4E";
    "theme.bar.menus.border.color" = "#0066FF";
    "theme.bar.menus.border.size" = "0.06em";
    "theme.bar.menus.border.radius" = "0.6em";
    "theme.bar.menus.popover.background" = "#0A0A0B";
    "theme.bar.menus.popover.text" = "#F0F0F2";
    "theme.bar.menus.listitems.active" = "#0066FF";
    "theme.bar.menus.icons.active" = "#0066FF";
    "theme.bar.menus.switch.enabled" = "#0066FF";
    "theme.bar.menus.check_radio_button.active" = "#0066FF";
    "theme.bar.menus.buttons.default" = "#0066FF";
    "theme.bar.menus.buttons.active" = "#0066FF";
    "theme.bar.menus.progressbar.foreground" = "#0066FF";
    "theme.bar.menus.progressbar.background" = "#1A1A1E";
    "theme.bar.menus.slider.primary" = "#0066FF";
    "theme.bar.menus.slider.background" = "#1A1A1E";
    "theme.bar.menus.slider.backgroundhover" = "#2A2A3E";
    "theme.bar.menus.tooltip.background" = "#0A0A0B";
    "theme.bar.menus.tooltip.text" = "#F0F0F2";
    "theme.bar.menus.dropdownmenu.background" = "#0A0A0B";
    "theme.bar.menus.dropdownmenu.text" = "#F0F0F2";

    # ─── Dashboard menu theme ──────────────────────────────────
    "theme.bar.menus.menu.dashboard.background" = "#0A0A0B";
    "theme.bar.menus.menu.dashboard.card" = "#1A1A1E";
    "theme.bar.menus.menu.dashboard.profile.name" = "#F0F0F2";

  };
}
