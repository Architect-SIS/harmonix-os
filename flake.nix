{
  description = "Harmonix OS — Sovereign Builder Operating System";

  inputs = {
    # ═══════════════════════════════════════════════════════════════
    # TIER 1: NixOS Foundation
    # ═══════════════════════════════════════════════════════════════
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Security: ephemeral root — only declared paths persist
    impermanence.url = "github:nix-community/impermanence";

    # Security: encrypted secrets management (activated post-install)
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ═══════════════════════════════════════════════════════════════
    # TIER 6: Hyprland Desktop Environment
    # ═══════════════════════════════════════════════════════════════
    hyprland.url = "github:hyprwm/Hyprland";

    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # ═══════════════════════════════════════════════════════════════
    # TIER 5: AgentZero Framework (non-flake, vendored)
    # ═══════════════════════════════════════════════════════════════
    agent-zero = {
      url = "github:frdel/agent-zero";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix,
              hyprland, hyprland-plugins, hyprpanel, agent-zero, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = false;  # Sovereignty: no proprietary packages
    };
  in
  {
    # ═══════════════════════════════════════════════════════════════
    # THE ONE COMMAND: sudo nixos-install --flake .#harmonix
    # Post-install:    sudo nixos-rebuild switch --flake .#harmonix
    # ═══════════════════════════════════════════════════════════════
    nixosConfigurations.harmonix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Hardware (generated per-machine)
        ./system/hardware-configuration.nix

        # Tier 1: Foundation
        ./system/core.nix
        ./system/security.nix
        ./system/networking.nix
        ./system/containers.nix
        ./system/users.nix

        # Tier 6: Desktop
        ./desktop/hyprland.nix
        ./desktop/agui-renderer.nix

        # Tier 5: Agent Brain
        ./agents/agent-zero.nix

        # Tier 4: Builder Mode
        ./builder/builder.nix

        # Security modules
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops

        # Home Manager (user-space config)
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.architect = import ./home/default.nix;
        }
      ];
    };

    # Development shell for working on Harmonix OS itself
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nil           # Nix LSP
        nixfmt-rfc-style  # Nix formatter
        sops          # Secret management
        age           # Encryption
      ];
      shellHook = ''
        echo "═══════════════════════════════════════════"
        echo "  Harmonix OS — Development Shell"
        echo "  ΣΔ → 0"
        echo "═══════════════════════════════════════════"
      '';
    };
  };
}
