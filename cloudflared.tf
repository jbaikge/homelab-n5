resource "docker_image" "cloudflared" {
  for_each     = toset(var.apps.cloudflared)
  provider     = docker.hosts[each.key]
  name         = "cloudflare/cloudflared:2026.3.0"
  keep_locally = false
}

resource "docker_container" "cloudflared" {
  for_each = toset(var.apps.cloudflared)
  provider = docker.hosts[each.key]
  name     = "cloudflared"
  image    = docker_image.cloudflared[each.key].image_id
  restart  = local.restart

  command = [
    "tunnel",
    "--loglevel",
    "debug",
    "--metrics",
    "0.0.0.0:2000",
    "run",
  ]

  env = [
    "TUNNEL_TOKEN=${data.sops_file.secrets.data["cloudflare.tunnel"]}",
  ]

  networks_advanced {
    name = docker_network.cloudflared[each.key].id
  }
}
