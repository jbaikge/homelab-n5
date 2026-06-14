resource "docker_image" "homebox" {
  provider     = docker.hosts[var.apps.homebox]
  name         = "ghcr.io/sysadminsmedia/homebox:0.26.1"
  keep_locally = false
}

resource "docker_container" "homebox" {
  provider = docker.hosts[var.apps.homebox]
  name     = "homebox"
  hostname = "homebox"
  image    = docker_image.homebox.image_id
  restart  = local.restart

  env = [
    "HBOX_AUTH_API_KEY_PEPPER=${data.sops_file.secrets.data["homebox.pepper"]}",
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.homebox.rule"
    value = "Host(`homebox.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.homebox.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.homebox.loadbalancer.server.port"
    value = "7745"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.homebox].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/data"
    host_path      = "/mnt/tank/apps/homebox"
    read_only      = false
  }
}
