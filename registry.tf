resource "docker_image" "registry" {
  provider     = docker.hosts[var.apps.registry]
  name         = "registry:3.1.1"
  keep_locally = false
}

resource "docker_container" "registry" {
  provider = docker.hosts[var.apps.registry]
  name     = "registry"
  hostname = "registry"
  image    = docker_image.registry.image_id
  restart  = local.restart

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.registry.rule"
    value = "Host(`registry.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.registry.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.registry.loadbalancer.server.port"
    value = "5000"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.gitea].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/var/lib/registry"
    host_path      = "/mnt/tank/apps/registry"
    read_only      = false
  }
}
