resource "docker_image" "gotenberg" {
  provider     = docker.hosts[var.apps.gotenberg]
  name         = "docker.io/gotenberg/gotenberg:8.32.0"
  keep_locally = false
}

resource "docker_container" "gotenberg" {
  provider = docker.hosts[var.apps.gotenberg]
  name     = "gotenberg"
  hostname = "gotenberg"
  image    = docker_image.gotenberg.image_id
  restart  = local.restart

  command = [
    "gotenberg",
    "--chromium-disable-javascript=true",
    "--chromium-allow-list=file:///tmp/.*",
  ]

  networks_advanced {
    name = docker_network.paperless.id
  }
}
