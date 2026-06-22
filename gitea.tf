resource "docker_image" "gitea" {
  provider     = docker.hosts[var.apps.gitea]
  name         = "docker.gitea.com/gitea:1.26.4"
  keep_locally = false
}

resource "docker_container" "gitea" {
  provider = docker.hosts[var.apps.gitea]
  name     = "gitea"
  hostname = "gitea"
  image    = docker_image.gitea.image_id
  restart  = local.restart

  env = [
    "USER_UID=1000",
    "USER_GID=1000",
    "GITEA__database__DB_TYPE=postgres",
    "GITEA__database__HOST=postgres:5432",
    "GITEA__database__NAME=${data.sops_file.secrets.data["gitea.db.database"]}",
    "GITEA__database__USER=${data.sops_file.secrets.data["gitea.db.username"]}",
    "GITEA__database__PASSWD=${data.sops_file.secrets.data["gitea.db.password"]}",
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.gitea.rule"
    value = "Host(`git.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.gitea.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.gitea.loadbalancer.server.port"
    value = "3000"
  }

  networks_advanced {
    name = docker_network.database.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.gitea].id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/data"
    host_path      = "/mnt/tank/apps/gitea"
    read_only      = false
  }

  depends_on = [
    docker_container.postgres
  ]
}
