# docker run --restart=unless-stopped --name openspeedtest -d -p 80:3000 -p 443:3001 openspeedtest/latest
# https://hub.docker.com/r/openspeedtest/latest/tags
resource "docker_image" "openspeedtest" {
  provider     = docker.hosts[var.apps.openspeedtest]
  name         = "openspeedtest/latest:v2.0.6"
  keep_locally = false
}

resource "docker_container" "openspeedtest" {
  provider = docker.hosts[var.apps.openspeedtest]
  name     = "openspeedtest"
  hostname = "openspeedtest"
  image    = docker_image.openspeedtest.image_id
  restart  = "unless-stopped"

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.openspeedtest.rule"
    value = "Host(`openspeed.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.openspeedtest.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.openspeedtest.tls"
    value = "true"
  }

  labels {
    label = "traefik.http.services.openspeedtest.loadbalancer.server.port"
    value = "3000"
  }

  labels {
    label = "traefik.http.routers.openspeedtest.middlewares"
    value = "limit"
  }

  labels {
    label = "traefik.http.middlewares.limit.buffering.maxRequestBodyBytes"
    value = tostring(35 * 1024 * 1024)
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.openspeedtest].id
  }

  ports {
    internal = 3000
    external = 16385
    ip       = var.hosts[var.apps.openspeedtest].service_ipv4
    protocol = "tcp"
  }
}
