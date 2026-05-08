resource "docker_image" "open_webui" {
  provider     = docker.hosts[var.apps.open_webui]
  name         = "ghcr.io/open-webui/open-webui:v0.9.2"
  keep_locally = false
}

resource "docker_container" "open_webui" {
  provider = docker.hosts[var.apps.open_webui]
  name     = "open-webui"
  hostname = "open-webui"
  image    = docker_image.open_webui.image_id
  restart  = local.restart

  env = [
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
    "OLLAMA_BASE_URL=http://ollama:11434",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.open_webui.rule"
    value = "Host(`open-webui.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.open_webui.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.open_webui.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.ollama.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.open_webui].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/app/backend/data"
    host_path      = "/mnt/tank/apps/open-webui"
    read_only      = false
  }
}
