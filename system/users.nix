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

      # Password strategy for ephemeral root (tmpfs wipes /etc/shadow every boot):
      #
      # initialPassword is set here so NixOS always has a working login.
      # After boot, run `passwd` to set your real password — it persists
      # because /etc/shadow is now in the impermanence persist list.
      #
      # Once stable, replace with hashedPasswordFile pointing to /persist.
      initialPassword = "harmonix";

      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAA... architect@harmonix"
      ];
    };

    # No root login
    users.root.hashedPassword = "!";
  };
}
