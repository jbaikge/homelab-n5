resource "docker_image" "birdnet_go" {
  provider     = docker.hosts[var.apps.birdnet_go]
  name         = "ghcr.io/tphakala/birdnet-go:nightly-20260322"
  keep_locally = false
}

resource "docker_container" "birdnet_go" {
  provider = docker.hosts[var.apps.birdnet_go]
  name     = "birdnet_go"
  hostname = "birdnet_go"
  image    = docker_image.birdnet_go.image_id
  restart  = local.restart

  env = [
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
    "BIRDNET_LATITUDE=${data.sops_file.secrets.data["location.latitude"]}",
    "BIRDNET_LONGITUDE=${data.sops_file.secrets.data["location.longitude"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.birdnetgo.rule"
    value = "Host(`birds.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.birdnetgo.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.birdnetgo.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.birdnet_go].id
  }

  volumes {
    container_path = "/config"
    host_path      = "/mnt/tank/apps/birdnet/config"
    read_only      = false
  }

  volumes {
    container_path = "/data"
    host_path      = "/mnt/tank/apps/birdnet/data"
    read_only      = false
  }
}
