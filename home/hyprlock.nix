# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Hyprlock Screen Lock
# ═══════════════════════════════════════════════════════════════
{ config, pkgs, lib, ... }:

{
  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        grace = 5
        hide_cursor = true
        no_fade_in = false
    }

    background {
        monitor =
        path = screenshot
        blur_passes = 4
        blur_size = 8
        noise = 0.02
        contrast = 0.9
        brightness = 0.6
        vibrancy = 0.2
        color = rgba(0A0A0Bff)
    }

    label {
        monitor =
        text = cmd[update:1000] echo "$(date +"%H:%M")"
        color = rgba(F0F0F2ff)
        font_size = 72
        font_family = Inter
        position = 0, 120
        halign = center
        valign = center
    }

    label {
        monitor =
        text = cmd[update:60000] echo "$(date +"%A, %B %d")"
        color = rgba(F0F0F2aa)
        font_size = 18
        font_family = Inter
        position = 0, 50
        halign = center
        valign = center
    }

    label {
        monitor =
        text = Harmonix OS
        color = rgba(0066FFaa)
        font_size = 12
        font_family = JetBrainsMono Nerd Font
        position = 0, -180
        halign = center
        valign = center
    }

    input-field {
        monitor =
        size = 280, 48
        outline_thickness = 2
        dots_size = 0.25
        dots_spacing = 0.2
        dots_center = true
        outer_color = rgba(0066FFee)
        inner_color = rgba(1A1A1Eff)
        font_color = rgba(F0F0F2ff)
        fade_on_empty = true
        placeholder_text = <span foreground="##666666">Authenticate...</span>
        hide_input = false
        rounding = 12
        check_color = rgba(00CC66ff)
        fail_color = rgba(FF4444ff)
        fail_text = <span foreground="##FF4444">Access Denied</span>
        position = 0, -50
        halign = center
        valign = center
    }
  '';
}
