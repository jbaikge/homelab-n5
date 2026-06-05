resource "docker_image" "influxdb" {
  provider     = docker.hosts[var.apps.influxdb]
  name         = "influxdb:2.9.1"
  keep_locally = false
}

resource "docker_container" "influxdb" {
  provider = docker.hosts[var.apps.influxdb]
  name     = "influxdb"
  hostname = "influxdb"
  image    = docker_image.influxdb.image_id
  restart  = local.restart

  env = [
    "DOCKER_INFLUXDB_INIT_MODE=setup",
    "DOCKER_INFLUXDB_INIT_ORG=${data.sops_file.secrets.data["influxdb.init.organization"]}",
    "DOCKER_INFLUXDB_INIT_BUCKET=${data.sops_file.secrets.data["influxdb.init.bucket"]}",
    "DOCKER_INFLUXDB_INIT_USERNAME=${data.sops_file.secrets.data["influxdb.init.username"]}",
    "DOCKER_INFLUXDB_INIT_PASSWORD=${data.sops_file.secrets.data["influxdb.init.password"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.influxdb.rule"
    value = "Host(`influxdb.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.influxdb.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.influxdb.loadbalancer.server.port"
    value = "8086"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.influxdb].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/etc/influxdb2"
    host_path      = "/mnt/dozer/databases/influxdb2/config"
    read_only      = false
  }

  volumes {
    container_path = "/var/lib/influxdb2"
    host_path      = "/mnt/dozer/databases/influxdb2/data"
    read_only      = false
  }
}
