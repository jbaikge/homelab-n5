resource "docker_image" "bentopdf" {
  provider     = docker.hosts[var.apps.bentopdf]
  name         = "ghcr.io/alam00000/bentopdf:v2.8.3"
  keep_locally = false
}

resource "docker_container" "bentopdf" {
  provider = docker.hosts[var.apps.bentopdf]
  name     = "bentopdf"
  image    = docker_image.bentopdf.image_id
  restart  = "unless-stopped"

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.bentopdf.rule"
    value = "Host(`pdf.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.bentopdf.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.bentopdf.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.bentopdf].id
  }
}
