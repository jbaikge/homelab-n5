resource "docker_image" "homebox_calendar" {
  provider     = docker.hosts[var.apps.homebox_calendar]
  name         = "registry.${data.sops_file.secrets.data["domain.tld"]}/homebox-calendar:v0.0.2"
  keep_locally = false
}

resource "docker_container" "homebox_calendar" {
  provider = docker.hosts[var.apps.homebox_calendar]
  name     = "homebox-calendar"
  hostname = "homebox-calendar"
  image    = docker_image.homebox_calendar.image_id
  restart  = local.restart

  env = [
    "LISTEN_ADDRESS=:8080",
    "HOMEBOX_URL=http://homebox:7745",
    "HOMEBOX_TOKEN=${data.sops_file.secrets.data["homebox.calendar.token"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.homebox_calendar.rule"
    value = "Host(`homebox-calendar.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.homebox_calendar.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.homebox_calendar.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.homebox.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.homebox].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  depends_on = [
    docker_container.homebox
  ]
}
