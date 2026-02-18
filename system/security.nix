# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Security Hardening
# ═══════════════════════════════════════════════════════════════
# Ephemeral root. Encrypted secrets (post-install). Minimal attack surface.
# ΣΔ → 0
{ config, pkgs, lib, inputs, ... }:

{
  # ─── Harmonix Options ─────────────────────────────────────────
  options.harmonix = {
    sopsEnabled = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable SOPS secret decryption. Set to true after age key setup.";
    };
  };

  config = {

    # ─── Impermanence (Ephemeral Root) ──────────────────────────
    # Only declared paths survive reboot. Everything else is wiped.
    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd"
        "/var/lib/tailscale"
        "/var/lib/containers"
        "/etc/NetworkManager/system-connections"
      ];
      files = [
        "/etc/machine-id"
        "/etc/ssh/ssh_host_ed25519_key"
        "/etc/ssh/ssh_host_ed25519_key.pub"
      ];
      users.architect = {
        directories = [
          ".config"
          ".local/share"
          ".cache"
          ".ssh"
          "harmonix"
          "harmonix-os"
          "documents"
          ".gnupg"
          # Agent directories (consolidated from agent-zero.nix)
          "harmonix/agents"
          # Builder directories (consolidated from builder.nix)
          "harmonix/builder"
          "harmonix/products"
        ];
        files = [
          ".zsh_history"
        ];
      };
    };

    # ─── SOPS (Encrypted Secrets) — Conditional ─────────────────
    # Activate AFTER first boot by setting harmonix.sopsEnabled = true
    # and ensuring age key exists at the path below.
    sops = lib.mkIf config.harmonix.sopsEnabled {
      defaultSopsFile = ../secrets/secrets.yaml;
      defaultSopsFormat = "yaml";

      age.keyFile = "/persist/home/architect/.config/sops/age/keys.txt";

      secrets = {
        "openrouter/api_key" = {
          owner = "architect";
          group = "users";
          mode = "0400";
        };
        "tailscale/auth_key" = {
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };
    };

    # ─── Kernel Hardening ───────────────────────────────────────
    boot.kernel.sysctl = {
      # Network hardening
      "net.ipv4.conf.all.rp_filter" = 1;
      "net.ipv4.conf.default.rp_filter" = 1;
      "net.ipv4.icmp_echo_ignore_broadcasts" = 1;
      "net.ipv4.conf.all.accept_redirects" = 0;
      "net.ipv4.conf.default.accept_redirects" = 0;
      "net.ipv6.conf.all.accept_redirects" = 0;
      "net.ipv6.conf.default.accept_redirects" = 0;
      "net.ipv4.conf.all.send_redirects" = 0;
      "net.ipv4.conf.default.send_redirects" = 0;
      "net.ipv4.tcp_syncookies" = 1;

      # Kernel hardening
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_bpf_disabled" = 1;
      "kernel.yama.ptrace_scope" = 1;
    };

    # ─── Firewall ───────────────────────────────────────────────
    networking.firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
      trustedInterfaces = [ "tailscale0" ];
    };

    # ─── SSH Hardening ──────────────────────────────────────────
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
        KbdInteractiveAuthentication = false;
        X11Forwarding = false;
        MaxAuthTries = 3;
      };
      # Listen on all interfaces — Tailscale firewall handles access control.
      # After Tailscale is up, you can restrict to Tailscale IP only.
    };

    # ─── Sudo Hardening ────────────────────────────────────────
    security.sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
        Defaults passwd_timeout = 1
      '';
    };

    # ─── Audit ──────────────────────────────────────────────────
    security.auditd.enable = true;
    security.audit = {
      enable = true;
      rules = [
        "-a exit,always -F arch=b64 -S execve"
      ];
    };
  };
}
