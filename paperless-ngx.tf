resource "docker_image" "paperless_ngx" {
  provider     = docker.hosts[var.apps.paperless_ngx]
  name         = "ghcr.io/paperless-ngx/paperless-ngx:2.20.15"
  keep_locally = false
}

resource "docker_container" "paperless_ngx" {
  provider = docker.hosts[var.apps.paperless_ngx]
  name     = "paperless-ngx"
  hostname = "paperless-ngx"
  image    = docker_image.paperless_ngx.image_id
  restart  = "unless-stopped"

  env = [
    "PAPERLESS_ADMIN_PASSWORD=${data.sops_file.secrets.data["paperless.admin.password"]}",
    "PAPERLESS_ADMIN_USER=${data.sops_file.secrets.data["paperless.admin.username"]}",
    # "PAPERLESS_CONSUMPTION_DIR=/srv/consume",
    # "PAPERLESS_DATA_DIR=/srv/data",
    "PAPERLESS_DATE_ORDER=MDY",
    "PAPERLESS_DBHOST=postgres",
    "PAPERLESS_DBNAME=${data.sops_file.secrets.data["paperless.db.database"]}",
    "PAPERLESS_DBPASS=${data.sops_file.secrets.data["paperless.db.password"]}",
    "PAPERLESS_DBUSER=${data.sops_file.secrets.data["paperless.db.username"]}",
    # "PAPERLESS_MEDIA_ROOT=/srv/media",
    "PAPERLESS_OCR_USER_ARGS={\"continue_on_soft_render_error\": true}",
    "PAPERLESS_REDIS=redis://redis:6379",
    "PAPERLESS_REDIS_PREFIX=paperless",
    "PAPERLESS_TIKA_ENABLED=1",
    "PAPERLESS_TIKA_ENDPOINT=http://tika:9998",
    "PAPERLESS_TIKA_GOTENBERG_ENDPOINT=http://gotenberg:3000",
    "PAPERLESS_TIME_ZONE=${data.sops_file.secrets.data["location.timezone"]}",
    "PAPERLESS_URL=https://docs.${data.sops_file.secrets.data["domain.tld"]}",
    "USERMAP_GID=1000",
    "USERMAP_UID=1000",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.paperless.rule"
    value = "Host(`docs.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.paperless.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.paperless.loadbalancer.server.port"
    value = "8000"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.paperless.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.paperless_ngx].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/usr/src/paperless/consume"
    host_path      = "/mnt/tank/apps/paperless/consume"
    read_only      = false
  }

  volumes {
    container_path = "/usr/src/paperless/data"
    host_path      = "/mnt/tank/apps/paperless/data"
    read_only      = false
  }

  volumes {
    container_path = "/usr/src/paperless/export"
    host_path      = "/mnt/tank/apps/paperless/export"
    read_only      = false
  }

  volumes {
    container_path = "/usr/src/paperless/media"
    host_path      = "/mnt/tank/apps/paperless/media"
    read_only      = false
  }
}
