resource "docker_image" "gitea_runner" {
  provider     = docker.hosts[var.apps.gitea_runner]
  name         = "docker.io/gitea/runner:3.3.2-dind"
  keep_locally = false
}

resource "docker_container" "gitea_runner" {
  provider   = docker.hosts[var.apps.gitea_runner]
  name       = "gitea-runner"
  hostname   = "gitea-runner"
  image      = docker_image.gitea_runner.image_id
  restart    = local.restart
  privileged = true

  dns = [
    for host in var.apps.blocky : var.hosts[host].service_ipv4
  ]

  env = [
    "GITEA_INSTANCE_URL=https://git.${data.sops_file.secrets.data["domain.tld"]}",
    "GITEA_RUNNER_REGISTRATION_TOKEN=${data.sops_file.secrets.data["gitea.runner.token"]}",
  ]

  networks_advanced {
    name = docker_network.gitea.id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/data"
    host_path      = "/mnt/tank/apps/gitea-runner"
    read_only      = false
  }

  depends_on = [
    docker_container.gitea
  ]
}
