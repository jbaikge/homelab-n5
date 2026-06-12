resource "docker_image" "scrutiny_collector" {
  for_each     = toset(var.apps.scrutiny_collector)
  provider     = docker.hosts[each.key]
  name         = "ghcr.io/analogj/scrutiny:v0.9.2-collector"
  keep_locally = false
}

resource "docker_container" "scrutiny_collector" {
  for_each = toset(var.apps.scrutiny_collector)
  provider = docker.hosts[each.key]
  name     = "scrutiny-collector"
  hostname = "scrutiny-collector"
  image    = docker_image.scrutiny_collector[each.key].image_id
  restart  = local.restart

  env = [
    "COLLECTOR_API_ENDPOINT=http://scrutiny-web:8080",
    "COLLECTOR_HOST_ID=${each.key}",
    "COLLECTOR_RUN_STARTUP=false",
  ]

  capabilities {
    add = [
      "CAP_SYS_RAWIO",
    ]
  }

  # devices {
  #   host_path = "/dev/nvme0n1"
  # }

  devices {
    host_path = "/dev/sda"
  }

  devices {
    host_path = "/dev/sdb"
  }

  devices {
    host_path = "/dev/sdc"
  }

  devices {
    host_path = "/dev/sdd"
  }

  devices {
    host_path = "/dev/sde"
  }

  networks_advanced {
    name = docker_network.scrutiny.id
  }

  volumes {
    container_path = "/run/udev"
    host_path      = "/run/udev"
    read_only      = true
  }
}
