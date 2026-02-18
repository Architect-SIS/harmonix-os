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
      initialHashedPassword = "$6$VnZMK2Hfo1xX7d3Z$bR7LUYwe.mOb7lGZzxeO33opYT0iSJRzczld959ADoJ4g8XcM73nuHI547RvdYvyHQ0GrLZtAcXsqyz0yuSHI.";

      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAA... architect@harmonix"
      ];
    };

    # No root login
    users.root.hashedPassword = "!";
  };
}
