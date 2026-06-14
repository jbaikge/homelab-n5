resource "docker_image" "iperf3" {
  provider     = docker.hosts[var.apps.iperf3]
  name         = "mlabbe/iperf3:3.19.1-r1"
  keep_locally = false
}

resource "docker_container" "iperf3" {
  provider = docker.hosts[var.apps.iperf3]
  name     = "iperf3"
  hostname = "iperf3"
  image    = docker_image.iperf3.image_id
  restart  = local.restart

  ports {
    internal = 5201
    external = 5201
    ip       = var.hosts[var.apps.iperf3].service_ipv4
    protocol = "tcp"
  }

  ports {
    internal = 5201
    external = 5201
    ip       = var.hosts[var.apps.iperf3].service_ipv4
    protocol = "udp"
  }
}
