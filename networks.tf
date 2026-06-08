resource "docker_network" "cloudflared" {
  for_each = toset(var.apps.cloudflared)
  provider = docker.hosts[each.key]
  name     = "cloudflared"
  ipv6     = true
}

resource "docker_network" "database" {
  provider = docker.hosts[var.apps.adminer]
  name     = "database"
  ipv6     = true
}

resource "docker_network" "dns" {
  for_each = toset(var.apps.blocky)
  provider = docker.hosts[each.key]
  name     = "dns"
  ipv6     = true
}

resource "docker_network" "home_assistant" {
  provider = docker.hosts[var.apps.home_assistant]
  name     = "home-assistant"
  ipv6     = false
}

resource "docker_network" "ollama" {
  provider = docker.hosts[var.apps.ollama]
  name     = "ollama"
  ipv6     = false
}

resource "docker_network" "paperless" {
  provider = docker.hosts[var.apps.paperless_ngx]
  name     = "paperless"
  ipv6     = true
}

resource "docker_network" "scrutiny" {
  provider = docker.hosts[var.apps.scrutiny_web]
  name     = "scrutiny"
  ipv6     = false
}

resource "docker_network" "traefik" {
  for_each = toset(var.apps.traefik)
  provider = docker.hosts[each.key]
  name     = "traefik"
  ipv6     = true
}
