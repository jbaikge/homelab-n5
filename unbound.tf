resource "docker_image" "unbound" {
  for_each     = toset(var.apps.unbound)
  provider     = docker.hosts[each.key]
  name         = "ghcr.io/klutchell/unbound:v1.24.1"
  keep_locally = false
}

resource "docker_container" "unbound" {
  for_each = toset(var.apps.unbound)
  provider = docker.hosts[each.key]
  name     = "unbound"
  hostname = "unbound"
  image    = docker_image.unbound[each.key].image_id

  networks_advanced {
    name = docker_network.dns[each.key].id
  }

  # Open an extra external port for testing unbound directly
  ports {
    internal = 53
    external = 5335
    ip       = var.hosts[each.key].service_ip
    protocol = "udp"
  }

  upload {
    file = "/etc/unbound/custom.conf.d/private-domain.conf"

    content = templatefile("${path.module}/files/unbound.conf", {
      private_domain = data.sops_file.secrets.data["cluster.tld"]
    })
  }
}
