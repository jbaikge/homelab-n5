locals {
  networks = {
    "paperless" = var.apps.paperless_ngx
    "database"  = var.apps.adminer
  }
}

resource "docker_network" "network" {
  for_each = local.networks
  provider = docker.hosts[each.value]
  name     = each.key
  ipv6     = true
}

resource "docker_network" "dns" {
  for_each = toset(var.apps.blocky)
  provider = docker.hosts[each.key]
  name     = "dns"
  ipv6     = true
}
