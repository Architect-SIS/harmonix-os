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
      createHome = true;
      home = "/home/architect";
      description = "The Architect";
      shell = pkgs.zsh;
      extraGroups = [
        "wheel"           # Sudo
        "networkmanager"  # Network management
        "video"           # GPU access
        "render"          # GPU rendering
        "audio"           # Audio
        "podman"          # Container management
        "docker"          # Docker access
      ];

      # Password: "harmonix" — hashedPassword forces this on every activation
      # Password: hownowbrowncow — survives ephemeral root. No more lockouts.
      hashedPassword = "$6$5wF44IXjL2W2F4uZ$iuoaCT77fiRdX1N2F.PPAKnbU7JDI.mjFSPPBApC8dZjnRD0zQg4zso2XyZrxuFbNFDvnuXafWRajyUbUngZx1";

      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJYIzlWlFsJNzZS+TCPYNOX35OGpyxu0Xn5n8NDioBCn architect-mac-key"
      ];
    };

    # No root login
    users.root.hashedPassword = "!";
  };

  # ─── Fix home dir ownership on every boot ─────────────────────
  # Impermanence recreates /home/architect as root:root.
  # This activation script ensures correct ownership before
  # Home Manager tries to create symlinks.
  system.activationScripts.fixHomeOwnership = lib.stringAfter [ "users" "groups" ] ''
    if [ -d /home/architect ] && [ "$(stat -c '%U' /home/architect)" = "root" ]; then
      chown architect:users /home/architect
      echo "Fixed /home/architect ownership (was root:root)"
    fi
  '';
}
