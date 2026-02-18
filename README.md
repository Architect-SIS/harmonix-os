# Harmonix OS

> **One Operating System. Zero Dependencies. Everything Inside.**

A stripped, security-hardened NixOS flake that contains the entire Harmonix ecosystem — agents, dashboard, tools, knowledge, and runtime — as one hermetically sealed, reproducible operating system.

## Install (The Easy Way)

```bash
# 1. Flash NixOS minimal ISO to USB #1
# 2. Copy this entire repo to USB #2
# 3. Boot the rig from USB #1
# 4. Run:

chmod +x bootstrap.sh
sudo ./bootstrap.sh

# That's it. The script handles EVERYTHING.
```

## Architecture

```
TIER 6  Hyprland + Hyprpanel + ag-ui Renderer
TIER 5  AgentZero (Architect / Mutant / Builder profiles)
TIER 4  AI Models via OpenRouter
TIER 3  DeltaZero Substrate
TIER 2  MCP Tools + .architect Framework + Knowledge Base
TIER 1  NixOS (hardened, impermanence, sops-nix, Tailscale)
```

## Post-Install

```bash
# Connect Tailscale
sudo tailscale up

# Push to GitHub
cd ~/harmonix-os
git remote set-url origin git@github.com:Architect-SIS/harmonix-os.git
git push -u origin main

# Set up SOPS secrets (optional)
age-keygen -o ~/.config/sops/age/keys.txt
# Update .sops.yaml with public key
# Edit harmonix.sopsEnabled = true in system/security.nix
# Encrypt: sops secrets/secrets.yaml
rebuild

# Start agent containers
sudo podman start agent-zero
sudo podman start searxng
```

## Key Commands

| Command | What it does |
|---|---|
| `rebuild` | `sudo nixos-rebuild switch --flake .#harmonix` |
| `update` | Update flake inputs |
| `ngc` | Garbage collect old generations |
| `Super+Return` | Open terminal |
| `Super+D` | App launcher |
| `Super+Q` | Close window |

## Structure

```
harmonix-os/
├── flake.nix                  # THE single flake
├── bootstrap.sh               # One-command installer
├── system/                    # NixOS modules
│   ├── core.nix               # Kernel, packages, services
│   ├── security.nix           # Impermanence, sops, hardening
│   ├── networking.nix         # Tailscale, firewall
│   ├── containers.nix         # Podman (rootless)
│   ├── users.nix              # Architect user
│   └── hardware-configuration.nix
├── desktop/                   # Hyprland desktop
│   ├── hyprland.nix           # System-level compositor
│   └── agui-renderer.nix      # Agent UI service
├── home/                      # Home Manager (user config)
│   ├── default.nix            # Entry point
│   ├── hyprland.nix           # Compositor settings + plugins
│   ├── hyprpanel.nix          # Panel config
│   ├── hyprlock.nix           # Lock screen
│   ├── hypridle.nix           # Idle management
│   ├── kitty.nix              # Terminal
│   ├── shell.nix              # Zsh + Starship
│   └── theme.nix              # GTK/Qt theming
├── agents/                    # AgentZero framework
│   ├── agent-zero.nix         # Container + integration
│   ├── profiles/              # Agent personas
│   ├── instruments/           # Agent tools
│   └── knowledge/             # RAG knowledge base
├── builder/                   # Build pipeline
│   └── builder.nix            # CLI + orchestrator
└── secrets/                   # Encrypted secrets (sops)
    └── secrets.yaml
```
