resource "docker_image" "postgres" {
  provider     = docker.hosts[var.apps.postgres]
  name         = "postgres:18.1" # TODO 18.3
  keep_locally = false
}

resource "docker_container" "postgres" {
  provider = docker.hosts[var.apps.postgres]
  name     = "postgres"
  hostname = "postgres"
  image    = docker_image.postgres.image_id
  restart  = "unless-stopped"

  env = [
    "POSTGRES_PASSWORD=${data.sops_file.secrets.data["postgres.password"]}",
  ]

  networks_advanced {
    name = docker_network.database.id
  }

  ports {
    internal = 5432
    external = 5432
    ip       = var.hosts[var.apps.postgres].service_ipv4
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/var/lib/postgresql"
    host_path      = "/mnt/dozer/databases/postgres"
    read_only      = false
  }
}
