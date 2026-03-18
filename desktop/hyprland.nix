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
    withUWSM = true;
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
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd \"uwsm start hyprland-uwsm.desktop\"";
        user = "architect";
      };
    };
  };

  # ─── Desktop Packages (System-Level) ──────────────────────────
  environment.systemPackages = with pkgs; [
    # Hyprland utilities
    hyprpaper
    hyprpicker
    hyprcursor
    hyprlock
    hypridle
    uwsm              # Universal Wayland Session Manager
    hyprpolkitagent

    # Wayland essentials
    wl-clipboard
    cliphist
    wl-screenrec
    grim
    slurp
    swappy

    # Application launcher
    rofi

    # File manager
    pcmanfm-qt

    # Document viewers
    zathura
    glow
    xdg-utils
    xdg-user-dirs

    # Desktop Shell Toolkit
    quickshell

    # RGB Controller
    openrgb

    # Text editor (GUI)
    vscodium

    # Web browser
    firefox

    # Terminal
    kitty

    # Notification daemon
    mako

    # Theming
    adwaita-icon-theme
    papirus-icon-theme

    # GTK/Qt integration
    gsettings-desktop-schemas
    glib
    dconf
    qt6.qtwayland
  ];

  # ─── Environment Variables ────────────────────────────────────
  # These are set BEFORE Hyprland starts (in the session env)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    SDL_VIDEODRIVER = "wayland";
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    GDK_BACKEND = "wayland";

    # Cursor theme — set BEFORE Hyprland starts so it finds the theme
    HYPRCURSOR_THEME = "Adwaita";
    HYPRCURSOR_SIZE = "24";
    XCURSOR_THEME = "Adwaita";
    XCURSOR_SIZE = "24";
  };

  # ─── dconf (GSettings backend — required for cursor/theme sync) ─
  programs.dconf.enable = true;

  # ─── Polkit (Privilege Escalation UI) ─────────────────────────
  security.polkit.enable = true;

  services.gnome.gnome-keyring.enable = true;

  # ─── OpenRGB (Hardware RGB Control) ─────────────────────────
  services.hardware.openrgb.enable = true;
  hardware.i2c.enable = true;
}
