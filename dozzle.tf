locals {
  dozzle = {
    version = "v10.4.1"
  }
}

resource "docker_image" "dozzle" {
  provider     = docker.hosts[var.apps.dozzle]
  name         = "ghcr.io/amir20/dozzle:${local.dozzle.version}"
  keep_locally = false
}

resource "docker_container" "dozzle" {
  provider = docker.hosts[var.apps.dozzle]
  name     = "dozzle"
  image    = docker_image.dozzle.image_id
  restart  = "unless-stopped"

  env = [
    format("DOZZLE_REMOTE_AGENT=%s", join(",", [for v in var.apps.dozzle_agent : "${var.hosts[v].service_ipv4}:7007"]))
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.dozzle.rule"
    value = "Host(`logs.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.dozzle.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.dozzle.loadbalancer.server.port"
    value = "8080"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }
}
