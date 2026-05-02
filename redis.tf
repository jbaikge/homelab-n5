resource "docker_image" "redis" {
  provider     = docker.hosts[var.apps.redis]
  name         = "redis:8.6.2"
  keep_locally = false
}

resource "docker_container" "redis" {
  provider = docker.hosts[var.apps.redis]
  name     = "redis"
  hostname = "redis"
  image    = docker_image.redis.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.network["database"].id
  }

  ports {
    internal = 6379
    external = 6379
    ip       = var.hosts[var.apps.redis].service_ipv4
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/data"
    host_path      = "/mnt/dozer/databases/redis"
    read_only      = false
  }
}

