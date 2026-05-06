resource "docker_image" "readeck" {
  provider     = docker.hosts[var.apps.readeck]
  name         = "codeberg.org/readeck/readeck:0.22.3"
  keep_locally = false
}

resource "docker_container" "readeck" {
  provider = docker.hosts[var.apps.readeck]
  name     = "readeck"
  hostname = "readeck"
  image    = docker_image.readeck.image_id
  restart  = local.restart

  env = [
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.readeck.rule"
    value = "Host(`readeck.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.readeck.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.readeck.loadbalancer.server.port"
    value = "8000"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.readeck].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/readeck"
    host_path      = "/mnt/tank/apps/readeck"
    read_only      = false
  }
}
