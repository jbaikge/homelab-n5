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

  ports {
    internal = 5000
    external = 5000
    ip       = var.hosts[var.apps.registry].service_ipv4
    protocol = "tcp"
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
