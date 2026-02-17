# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Kitty Terminal
# ═══════════════════════════════════════════════════════════════
{ config, pkgs, lib, ... }:

{
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = {
      window_padding_width = 12;
      confirm_os_window_close = 0;
      background_opacity = "0.92";
      dynamic_background_opacity = true;
      hide_window_decorations = true;
      cursor_shape = "beam";
      cursor_blink_interval = "0.5";
      url_style = "curly";
      detect_urls = true;
      enable_audio_bell = false;
      visual_bell_duration = "0.0";
      repaint_delay = 8;
      sync_to_monitor = true;

      foreground = "#F0F0F2";
      background = "#0A0A0B";
      selection_foreground = "#0A0A0B";
      selection_background = "#0066FF";
      cursor = "#0066FF";
      cursor_text_color = "#0A0A0B";

      color0 = "#1A1A1E"; color8 = "#374151";
      color1 = "#FF4444"; color9 = "#FF6666";
      color2 = "#00CC66"; color10 = "#33FF99";
      color3 = "#FFB800"; color11 = "#FFD54F";
      color4 = "#0066FF"; color12 = "#3399FF";
      color5 = "#7C3AED"; color13 = "#A855F7";
      color6 = "#06B6D4"; color14 = "#22D3EE";
      color7 = "#D1D5DB"; color15 = "#F0F0F2";

      tab_bar_style = "powerline";
      tab_powerline_style = "slanted";
      active_tab_foreground = "#0A0A0B";
      active_tab_background = "#0066FF";
      inactive_tab_foreground = "#D1D5DB";
      inactive_tab_background = "#1A1A1E";
    };
  };
}
