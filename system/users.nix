# ═══════════════════════════════════════════════════════════════
# Harmonix OS — User Configuration
# ═══════════════════════════════════════════════════════════════
# The Architect. One user. Full sovereignty.
# ΣΔ → 0
{ config, pkgs, lib, ... }:

{
  users = {
    mutableUsers = true;  # Allow passwd changes — set to false after stabilizing

    users.architect = {
      isNormalUser = true;
      description = "The Architect";
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"           # Sudo
        "networkmanager"  # Network management
        "video"           # GPU access
        "render"          # GPU rendering
        "audio"           # Audio
        "podman"          # Container management
      ];

      # Initial password — change after first boot with `passwd`
      # The bootstrap script replaces this with your actual hash.
      # Once stable, switch to hashedPasswordFile for impermanence.
      hashedPassword = "$6$MdpLfZH/gihPuiFm$aUD.kFVxuYxAbegI2UkxO8npKcJr3vZ1/4nGiTOvspzx70sZkE6t4IisRQp1tkXHi5fXqwasmfWjfvX/KOU7O.";

      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAA... architect@harmonix"
      ];
    };

    # No root login
    users.root.hashedPassword = "!";
  };
}
