{ config, pkgs, ... }:

{
  # ─── Mission Control Container ────────────────────────────────
  virtualisation.oci-containers.containers.mission-control = {
    image = "mission-control:latest";
    autoStart = true;

    ports = [
      "0.0.0.0:3000:3000"
    ];

    extraOptions = [
      "--memory=2g"
      "--cpus=2"
    ];
  };
}
