resource "docker_image" "traefik" {
  for_each     = toset(var.apps.traefik)
  provider     = docker.hosts[each.key]
  name         = "traefik:v3.6.14"
  keep_locally = false
}

resource "docker_container" "traefik" {
  for_each = toset(var.apps.traefik)
  provider = docker.hosts[each.key]
  name     = "traefik"
  hostname = "traefik"
  image    = docker_image.traefik[each.key].image_id
  restart  = "unless-stopped"

  env = [
    "CLOUDFLARE_EMAIL=${data.sops_file.secrets.data["cloudflare.email"]}",
    "CLOUDFLARE_DNS_API_TOKEN=${data.sops_file.secrets.data["cloudflare.token"]}",
  ]

  command = [
    # Entrypoints
    "--entrypoints.web.address=:80",
    "--entrypoints.web.http.redirections.entrypoint.to=websecure",
    "--entrypoints.web.http.redirections.entrypoint.scheme=https",
    "--entrypoints.web.http.redirections.entrypoint.permanent=true",
    "--entrypoints.websecure.address=:443",
    "--entrypoints.websecure.http.tls=true",
    "--entrypoints.websecure.http.tls.certresolver=le",
    "--entrypoints.websecure.http.tls.domains[0].main=${data.sops_file.secrets.data["domain.tld"]}",
    "--entrypoints.websecure.http.tls.domains[0].sans=*.${data.sops_file.secrets.data["domain.tld"]}",
    "--entrypoints.metrics.address=:8082",

    # Certificate Resolver
    # https://major.io/p/wildcard-letsencrypt-certificates-traefik-cloudflare/
    "--certificatesresolvers.le.acme.email=${data.sops_file.secrets.data["cloudflare.email"]}",
    "--certificatesresolvers.le.acme.storage=/letsencrypt/acme.json",
    "--certificatesresolvers.le.acme.dnschallenge=true",
    "--certificatesresolvers.le.acme.dnschallenge.provider=cloudflare",
    "--certificatesresolvers.le.acme.dnschallenge.delaybeforecheck=5",
    "--certificatesresolvers.le.acme.dnschallenge.resolvers=1.1.1.1:53,8.8.8.8:53",

    # Providers
    "--providers.docker=true",
    "--providers.docker.exposedbydefault=false",

    # API & Dashboard
    "--api.dashboard=true",
    "--api.insecure=false",

    # Observability
    "--log.level=INFO",
    "--accesslog=true",
    "--metrics.prometheus=true",
    "--metrics.prometheus.entrypoint=metrics",
    "--metrics.prometheus.addrouterslabels=true",
    "--metrics.prometheus.addserviceslabels=true",
  ]

  # Enable self-routing
  labels {
    label = "traefik.enable"
    value = "true"
  }

  # Dashboard routing
  labels {
    label = "traefik.http.routers.dashboard.rule"
    value = nonsensitive("Host(`${each.key}.${data.sops_file.secrets.data["domain.tld"]}`)")
  }

  labels {
    label = "traefik.http.routers.dashboard.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.routers.dashboard.tls.certresolver"
    value = "le"
  }

  labels {
    label = "traefik.http.routers.dashboard.service"
    value = "api@internal"
  }

  # Basic-auth middleware
  labels {
    label = "traefik.http.middlewares.dashboard-auth.basicauth.users"
    value = nonsensitive(data.sops_file.secrets.data["traefik.users"])
  }

  labels {
    label = "traefik.http.routers.dashboard.middlewares"
    value = "dashboard-auth@docker"
  }

  ports {
    internal = 80
    external = 80
    ip       = var.hosts[each.key].service_ipv4
    protocol = "tcp"
  }

  ports {
    internal = 443
    external = 443
    ip       = var.hosts[each.key].service_ipv4
    protocol = "tcp"
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/var/run/docker.sock"
    host_path      = "/var/run/docker.sock"
    read_only      = true
  }

  volumes {
    container_path = "/letsencrypt"
    host_path      = "/mnt/tank/apps/traefik"
    read_only      = false
  }
}
