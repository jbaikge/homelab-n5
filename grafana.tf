resource "docker_image" "grafana" {
  provider     = docker.hosts[var.apps.grafana]
  name         = "grafana/grafana:13.0.2"
  keep_locally = false
}

resource "docker_container" "grafana" {
  provider = docker.hosts[var.apps.grafana]
  name     = "grafana"
  hostname = "grafana"
  image    = docker_image.grafana.image_id
  restart  = local.restart

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.grafana.rule"
    value = "Host(`grafana.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.grafana.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.grafana.loadbalancer.server.port"
    value = "3000"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.grafana].id
  }

  volumes {
    container_path = "/var/lib/grafana"
    host_path      = "/mnt/tank/apps/grafana"
    read_only      = false
  }
}
