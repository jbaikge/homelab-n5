resource "docker_image" "tika" {
  provider     = docker.hosts[var.apps.tika]
  name         = "docker.io/apache/tika:3.3.0.0-full"
  keep_locally = false
}

resource "docker_container" "tika" {
  provider = docker.hosts[var.apps.tika]
  name     = "tika"
  hostname = "tika"
  image    = docker_image.tika.image_id
  restart  = "unless-stopped"

  networks_advanced {
    name = docker_network.paperless.id
  }
}
