resource "docker_image" "databasus" {
  provider     = docker.hosts[var.apps.databasus]
  name         = "databasus/databasus:v3.35.0"
  keep_locally = false
}

resource "docker_container" "databasus" {
  provider = docker.hosts[var.apps.databasus]
  name     = "databasus"
  hostname = "databasus"
  image    = docker_image.databasus.image_id
  restart  = "unless-stopped"

  env = [
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.databasus.rule"
    value = "Host(`databasus.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.databasus.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.databasus.loadbalancer.server.port"
    value = "4005"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.databasus].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/databasus-data"
    host_path      = "/mnt/tank/apps/databasus"
    read_only      = false
  }
}
