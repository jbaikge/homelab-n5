resource "docker_image" "prometheus" {
  provider     = docker.hosts[var.apps.prometheus]
  name         = "docker.io/prom/prometheus:v3.11.3"
  keep_locally = false
}

resource "docker_container" "prometheus" {
  provider = docker.hosts[var.apps.prometheus]
  name     = "prometheus"
  hostname = "prometheus"
  image    = docker_image.prometheus.image_id
  restart  = local.restart

  dns = [
    for host in var.hosts : host.service_ipv4
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.prometheus.rule"
    value = "Host(`prometheus.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.prometheus.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.prometheus.loadbalancer.server.port"
    value = "9090"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.prometheus].id
  }

  upload {
    file = "/etc/prometheus/prometheus.yml"

    content = templatefile("${path.module}/files/prometheus.yaml", {
      blocky_url           = data.sops_file.secrets.data["prometheus.blocky.url"]
      home_assistant_token = data.sops_file.secrets.data["prometheus.hass.token"]
      home_assistant_url   = data.sops_file.secrets.data["prometheus.hass.url"]
      waka_personal_token  = data.sops_file.secrets.data["prometheus.waka_personal.token"]
      waka_personal_url    = data.sops_file.secrets.data["prometheus.waka_personal.url"]
      waka_work_token      = data.sops_file.secrets.data["prometheus.waka_work.token"]
      waka_work_url        = data.sops_file.secrets.data["prometheus.waka_work.url"]
    })
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/prometheus"
    host_path      = "/mnt/dozer/databases/prometheus"
    read_only      = false
  }
}
