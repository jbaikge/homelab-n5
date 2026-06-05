resource "docker_image" "blocky" {
  for_each     = toset(var.apps.blocky)
  provider     = docker.hosts[each.key]
  name         = "ghcr.io/0xerr0r/blocky:v0.28.1"
  keep_locally = false
}

resource "docker_container" "blocky" {
  for_each = toset(var.apps.blocky)
  provider = docker.hosts[each.key]
  name     = "blocky"
  hostname = "blocky"
  image    = docker_image.blocky[each.key].image_id
  restart  = local.restart

  env = [
    "TZ=${data.sops_file.secrets.data["location.timezone"]}",
  ]

  networks_advanced {
    name = docker_network.dns[each.key].id
  }

  ports {
    internal = 53
    external = 53
    ip       = var.hosts[each.key].service_ipv4
    protocol = "tcp"
  }

  ports {
    internal = 53
    external = 53
    ip       = var.hosts[each.key].service_ipv4
    protocol = "udp"
  }

  ports {
    internal = 53
    external = 53
    ip       = var.hosts[each.key].service_ipv6
    protocol = "tcp"
  }

  ports {
    internal = 53
    external = 53
    ip       = var.hosts[each.key].service_ipv6
    protocol = "udp"
  }

  upload {
    file = "/app/config.yml"

    content = templatefile("${path.module}/files/blocky.yaml", {
      domain     = data.sops_file.secrets.data["domain.tld"]
      ash_ip     = var.old_hosts["ash"]
      cherry_ip  = var.old_hosts["cherry"]
      hickory_ip = var.old_hosts["hickory"]
      maple_ip   = var.old_hosts["maple"]
      oak_ip     = var.hosts["oak"].service_ipv4
    })
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  lifecycle {
    ignore_changes = [
      # Waiting for PR to fix port ordering
      ports,
    ]
  }

  depends_on = [
    docker_container.unbound,
  ]
}
