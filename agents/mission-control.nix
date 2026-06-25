{ config, pkgs, ... }:

{
  # ─── Mission Control Container ────────────────────────────────
  virtualisation.oci-containers.containers.mission-control = {
    image = "mission-control:latest";
    autoStart = true;

    ports = [
      "0.0.0.0:3000:3000"
    ];

    environment = {
      MC_ALLOWED_HOSTS = "localhost,127.0.0.1,100.75.154.33,harmonix";
      MC_ENABLE_HSTS = "0";
      MC_COOKIE_SECURE = "0";
    };

    extraOptions = [
      "--memory=2g"
      "--cpus=2"
    ];
  };
}
