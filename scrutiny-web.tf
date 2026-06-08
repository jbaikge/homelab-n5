resource "docker_image" "scrutiny_web" {
  provider     = docker.hosts[var.apps.scrutiny_web]
  name         = "ghcr.io/analogj/scrutiny:v0.9.2-web"
  keep_locally = false
}

resource "docker_container" "scrutiny_web" {
  provider = docker.hosts[var.apps.scrutiny_web]
  name     = "scrutiny-web"
  hostname = "scrutiny-web"
  image    = docker_image.scrutiny_web.image_id
  restart  = local.restart

  env = [
    "SCRUTINY_WEB_INFLUXDB_HOST=influxdb",
    "SCRUTINY_WEB_INFLUXDB_ORG=${data.sops_file.secrets.data["scrutiny.influxdb.org"]}",
    "SCRUTINY_WEB_INFLUXDB_BUCKET=${data.sops_file.secrets.data["scrutiny.influxdb.bucket"]}",
    "SCRUTINY_WEB_INFLUXDB_TOKEN=${data.sops_file.secrets.data["scrutiny.influxdb.token"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.scrutiny.rule"
    value = "Host(`scrutiny.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.scrutiny.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.scrutiny.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.scrutiny.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.scrutiny_web].id
  }

  volumes {
    container_path = "/opt/scrutiny/config"
    host_path      = "/mnt/tank/apps/scrutiny"
    read_only      = false
  }
}
