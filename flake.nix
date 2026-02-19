{
  description = "Harmonix OS — Sovereign Builder Operating System";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprpanel = {
      url = "github:Jas-SinghFSU/HyprPanel";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agent-zero = {
      url = "github:frdel/agent-zero";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, impermanence, sops-nix,
              hyprpanel, agent-zero, ... }@inputs:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = false;
    };
  in
  {
    nixosConfigurations.harmonix = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./system/hardware-configuration.nix
        ./system/core.nix
        ./system/security.nix
        ./system/networking.nix
        ./system/containers.nix
        ./system/users.nix
        ./desktop/hyprland.nix
        ./desktop/agui-renderer.nix
        ./agents/agent-zero.nix
        ./builder/builder.nix
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.architect = import ./home/default.nix;
        }
      ];
    };

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [ nil nixfmt-rfc-style sops age ];
      shellHook = ''
        echo "═══════════════════════════════════════════"
        echo "  Harmonix OS — Development Shell  ΣΔ → 0"
        echo "═══════════════════════════════════════════"
      '';
    };
  };
}
