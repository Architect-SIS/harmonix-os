{ config, lib, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "harmonix";
  networking.networkmanager.enable = true;

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.architect = {
    isNormalUser = true;
    description = "The Architect";
    initialPassword = "harmonix";
    extraGroups = [ "wheel" "networkmanager" "docker" "video" "render" "audio" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;

  programs.dconf.enable = true;

  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-volman   # removable media management
    ];
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd Hyprland";
        user = "greeter";
      };
    };
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes";
      PasswordAuthentication = true;
    };
  };

  networking.firewall.enable = false;

  # Tensor Field — 952GB dedicated AI/data drive
  fileSystems."/tensor_field" = {
    device = "/dev/disk/by-label/TENSOR_FIELD";
    fsType = "btrfs";
    options = [ "defaults" "noatime" ];
  };

  # Docker data on tensor_field
  virtualisation.docker = {
    enable = true;
    daemon.settings = {
      data-root = "/tensor_field/docker";
    };
  };

  environment.systemPackages = with pkgs; [
    vim git wget curl htop tmux zsh fastfetch
    nodejs_22 python3 docker-compose gcc rustup
    kitty wofi waybar mako grim slurp wl-clipboard
    swww networkmanagerapplet pavucontrol firefox
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    inter
  ];

  fonts.fontconfig.enable = true;

  services.gvfs.enable = true;  # mount, trash, and other Thunar functionality

  services.flatpak.enable = true;

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
  };

  hardware.graphics.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "26.05";
}
