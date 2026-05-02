resource "docker_image" "miniflux" {
  provider     = docker.hosts[var.apps.miniflux]
  name         = "ghcr.io/miniflux/miniflux:2.2.18"
  keep_locally = false
}

resource "docker_container" "miniflux" {
  provider = docker.hosts[var.apps.miniflux]
  name     = "miniflux"
  hostname = "miniflux"
  image    = docker_image.miniflux.image_id
  restart  = "unless-stopped"

  env = [
    "DATABASE_URL=postgres://${data.sops_file.secrets.data["miniflux.db.username"]}:${data.sops_file.secrets.data["miniflux.db.password"]}@postgres/miniflux?sslmode=disable",
    "RUN_MIGRATIONS=1",
    "CREATE_ADMIN=1",
    "ADMIN_USERNAME=${data.sops_file.secrets.data["miniflux.admin.username"]}",
    "ADMIN_PASSWORD=${data.sops_file.secrets.data["miniflux.admin.password"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.miniflux.rule"
    value = "Host(`rss.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.miniflux.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.miniflux.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.cloudflared[var.apps.miniflux].id
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.miniflux].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  depends_on = [
    docker_container.postgres
  ]
}
