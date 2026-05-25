resource "docker_image" "home_assistant" {
  provider     = docker.hosts[var.apps.home_assistant]
  name         = "ghcr.io/home-assistant/home-assistant:2026.3.4"
  keep_locally = false
}

resource "docker_container" "home_assistant" {
  provider = docker.hosts[var.apps.home_assistant]
  name     = "home-assistant"
  hostname = "home-assistant"
  image    = docker_image.home_assistant.image_id
  restart  = local.restart

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.home_assistant.rule"
    value = "Host(`home.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.home_assistant.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.home_assistant.loadbalancer.server.port"
    value = "8123"
  }

  networks_advanced {
    name = docker_network.home_assistant.id
  }

  networks_advanced {
    name = docker_network.cloudflared[var.apps.home_assistant].id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.home_assistant].id
  }

  volumes {
    container_path = "/config"
    volume_name    = "/mnt/tank/apps/home-assistant"
    read_only      = false
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
}
