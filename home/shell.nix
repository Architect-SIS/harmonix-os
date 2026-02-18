# ═══════════════════════════════════════════════════════════════
# Harmonix OS — Shell Configuration
# ═══════════════════════════════════════════════════════════════
{ config, pkgs, lib, ... }:

{
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    enableCompletion = true;

    history = {
      size = 50000;
      save = 50000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    shellAliases = {
      rebuild = "sudo nixos-rebuild switch --flake /persist/home/architect/harmonix-os#harmonix";
      update = "nix flake update /persist/home/architect/harmonix-os";
      ngc = "sudo nix-collect-garbage -d";
      ll = "ls -la --color=auto";
      ".." = "cd ..";
      "..." = "cd ../..";
      gs = "git status";
      ga = "git add";
      gcm = "git commit";
      gp = "git push";
      gl = "git log --oneline -20";
      hz = "cd ~/harmonix";
      hzos = "cd ~/harmonix-os";
    };

    initExtra = ''
      if [[ $SHLVL -eq 1 ]]; then
        echo ""
        echo "  ═══════════════════════════════════════"
        echo "  Harmonix OS — Sovereign Builder"
        echo "  ═══════════════════════════════════════"
        echo ""
      fi
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      format = lib.concatStrings [
        "[H](bold blue)"
        " $directory"
        "$git_branch"
        "$git_status"
        "$python"
        "$rust"
        "$nodejs"
        "$nix_shell"
        "$cmd_duration"
        "\n"
        "[>](bold purple) "
      ];
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncation_symbol = ".../";
      };
      git_branch = {
        format = " [$branch]($style)";
        style = "bold green";
      };
      git_status = {
        format = "[$all_status$ahead_behind]($style) ";
        style = "bold red";
      };
      cmd_duration = {
        min_time = 500;
        format = " [$duration]($style)";
        style = "bold yellow";
      };
      nix_shell = {
        format = " [$symbol$state]($style)";
        symbol = "nix ";
        style = "bold blue";
      };
      python = {
        format = " [$symbol$version]($style)";
        symbol = "py ";
        style = "bold yellow";
      };
      rust = {
        format = " [$symbol$version]($style)";
        symbol = "rs ";
        style = "bold red";
      };
      nodejs = {
        format = " [$symbol$version]($style)";
        symbol = "js ";
        style = "bold green";
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultOptions = [
      "--color=bg+:#1A1A1E,bg:#0A0A0B,fg:#F0F0F2,fg+:#F0F0F2"
      "--color=hl:#0066FF,hl+:#3399FF,info:#FFB800,marker:#00CC66"
      "--color=prompt:#7C3AED,spinner:#06B6D4,pointer:#FF4444,header:#0066FF"
      "--height=40%"
      "--layout=reverse"
      "--border=rounded"
    ];
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "base16";
      style = "numbers,changes,header";
    };
  };
}
