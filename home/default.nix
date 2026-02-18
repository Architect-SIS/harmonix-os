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
    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;

  # ─── Git ──────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    settings = {
      user.name = "Architect-SIS";
      user.email = "fabricatedkc@gmail.com";
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
