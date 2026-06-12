resource "docker_image" "glance" {
  provider     = docker.hosts[var.apps.glance]
  name         = "glanceapp/glance:v0.8.5"
  keep_locally = false
}

resource "docker_container" "glance" {
  provider = docker.hosts[var.apps.glance]
  name     = "glance"
  hostname = "glance"
  image    = docker_image.glance.image_id

  dns = [
    for host in var.apps.blocky : var.hosts[host].service_ipv4
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.glance.rule"
    value = "Host(`glance.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.glance.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.glance.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.glance].id
  }

  upload {
    file = "/app/config/glance.yml"

    content = templatefile("${path.module}/files/glance.yaml", {
      domain = data.sops_file.secrets.data["domain.tld"]
    })
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }
}
