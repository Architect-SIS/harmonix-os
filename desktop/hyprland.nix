# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Hyprland Desktop (System-Level)
# ═══════════════════════════════════════════════════════════════
# Wayland compositor with all add-ons. System-level enablement.
# User-level config in home/hyprland.nix via Home Manager.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  # ─── Hyprland (System Enable) ─────────────────────────────────
  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
  };

  # ─── XDG Portal (Screen Sharing, File Dialogs) ───────────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # ─── Session ──────────────────────────────────────────────────
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "architect";
      };
    };
  };

  # ─── Desktop Packages (System-Level) ──────────────────────────
  environment.systemPackages = with pkgs; [
    # Hyprland utilities (compositor itself is managed by programs.hyprland above)
    hyprpaper
    hyprpicker
    hyprcursor
    hyprlock
    hypridle

    # Wayland essentials
    wl-clipboard
    wl-screenrec
    grim
    slurp
    swappy

    # Application launcher (rofi-wayland merged into rofi in nixpkgs-unstable)
    rofi

    # File manager
    pcmanfm-qt

    # Terminal
    kitty

    # Notification daemon
    mako

    # Theming
    adwaita-icon-theme
    papirus-icon-theme

    # GTK/Qt integration
    gsettings-desktop-schemas
    qt6.qtwayland

    # Browser
    firefox
  ];

  # ─── Environment Variables ────────────────────────────────────
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland";
  };

  # ─── Polkit (Privilege Escalation UI) ─────────────────────────
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
}
