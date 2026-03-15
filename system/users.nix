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

      # Initial password — change after first boot with `passwd`
      # The bootstrap script replaces this with your actual hash.
      # Once stable, switch to hashedPasswordFile for impermanence.
      initialHashedPassword = "$6$0aFyLqSasScG7ZqE$mNFJMD4oOslci1S91hpFfRqbiUN8dBMofiTOYOiaHYTYBWmibmSu/aR.PV9eWa4xiEnty9EacfNlDy7qPO8sE/";

      openssh.authorizedKeys.keys = [
        # "ssh-ed25519 AAAA... architect@harmonix"
      ];
    };

    # No root login
    users.root.hashedPassword = "!";
  };
}
