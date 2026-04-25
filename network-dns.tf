resource "docker_network" "dns" {
  for_each = toset(var.apps.blocky)
  provider = docker.hosts[each.key]
  name     = "dns"
}
