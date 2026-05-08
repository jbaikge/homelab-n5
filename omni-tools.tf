resource "docker_image" "omni_tools" {
  provider     = docker.hosts[var.apps.omni_tools]
  name         = "iib0011/omni-tools:0.6.0"
  keep_locally = false
}

resource "docker_container" "omni_tools" {
  provider = docker.hosts[var.apps.omni_tools]
  name     = "omni-tools"
  hostname = "omni-tools"
  image    = docker_image.omni_tools.image_id
  restart  = local.restart

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.omni_tools.rule"
    value = "Host(`omni-tools.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.omni_tools.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.omni_tools.loadbalancer.server.port"
    value = "80"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.omni_tools].id
  }
}
