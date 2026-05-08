resource "docker_image" "it_tools" {
  provider     = docker.hosts[var.apps.it_tools]
  name         = "ghcr.io/corentinth/it-tools:2024.10.22-7ca5933"
  keep_locally = false
}

resource "docker_container" "it_tools" {
  provider = docker.hosts[var.apps.it_tools]
  name     = "it-tools"
  hostname = "it-tools"
  image    = docker_image.it_tools.image_id
  restart  = local.restart

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.it_tools.rule"
    value = "Host(`it-tools.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.it_tools.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.it_tools.loadbalancer.server.port"
    value = "80"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.it_tools].id
  }
}
