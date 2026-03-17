# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Home Manager (User Configuration)
# ═══════════════════════════════════════════════════════════════
# Everything user-level: Hyprland config, terminal, shell, editor.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ./hyprland.nix
    ./hyprpanel.nix
    ./hyprlock.nix
    ./hypridle.nix
    ./kitty.nix
    ./shell.nix
    ./theme.nix
  ];

  home = {
    username = "architect";
    homeDirectory = "/home/architect";

    # ─── Cursor Theme (fixes Hyprcursor/XCursor errors) ──────
    pointerCursor = {
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
      gtk.enable = true;
    };
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  # ─── XDG User Directories (Documents, Downloads, etc.) ──────
  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = "${config.home.homeDirectory}/harmonix";
      documents = "${config.home.homeDirectory}/documents";
      download = "${config.home.homeDirectory}/Downloads";
      music = "${config.home.homeDirectory}/music";
      pictures = "${config.home.homeDirectory}/pictures";
      videos = "${config.home.homeDirectory}/videos";
      publicShare = "${config.home.homeDirectory}/public";
      templates = "${config.home.homeDirectory}/templates";
    };
    mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = "pcmanfm-qt.desktop";
        "text/html" = "firefox.desktop";
        "x-scheme-handler/http" = "firefox.desktop";
        "x-scheme-handler/https" = "firefox.desktop";
        "application/pdf" = "org.pwmt.zathura.desktop";
      };
    };
  };

  # ─── Git ──────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Architect-SIS";
    userEmail = "fabricatedkc@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };

  # ─── Neovim ───────────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
  };

  # ─── Direnv (Auto-activate project envs) ─────────────────────
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
