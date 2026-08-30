resource "docker_image" "ollama" {
  provider     = docker.hosts[var.apps.ollama]
  name         = "ollama/ollama:0.33.2" # ROCM: ollama/ollama:0.33.2-rocm
  keep_locally = false
}

# Ref: https://technotim.com/posts/paperless-ngx-local-ai/
# Ref: https://github.com/Foundry81/ollama-rocm-n5pro/blob/main/docker-compose.yml
resource "docker_container" "ollama" {
  provider = docker.hosts[var.apps.ollama]
  name     = "ollama"
  hostname = "ollama"
  image    = docker_image.ollama.image_id
  restart  = local.restart

  # For ollama:rocm
  # group_add = [
  #   "44",  # video group
  #   "107", # render group
  #   "568", # AMD-Specific
  # ]

  env = [
    # for ollama:rocm
    # "HSA_OVERRIDE_GFX_VERSION=11.0.0",                        # Ensures ROCm sees the correct GPU architecture
    # "NVIDIA_VISIBLE_DEVICES=void",                            # Explicitly disable NVIDIA runtime
    # for vulkan
    "OLLAMA_VULKAN=1",
    "OLLAMA_IGPU_ENABLE=1",
    "OLLAMA_LLM_LIBRARY=vulkan", # Force Vulkan execution backend
    "GGML_VK_VISIBLE_DEVICES=0", # Target first GPU
    # common options
    "OLLAMA_HOST=0.0.0.0:11434",                              # Listen address for Ollama API
    "OLLAMA_MODELS=/ollama-models",                           # Path to models folder
    "TZ=${data.sops_file.secrets.data["location.timezone"]}", # Timezone
    "UMASK=002",                                              # File creation mask
    "UMASK_SET=002",
  ]

  devices {
    host_path      = "/dev/dri"
    container_path = "/dev/dri"
  }

  # For ollama:rocm
  # devices {
  #   host_path      = "/dev/kfd"
  #   container_path = "/dev/kfd"
  # }

  healthcheck {
    interval       = "10s"
    retries        = 30
    start_interval = "10s"
    timeout        = "5s"
    test           = ["timeout", "1", "bash", "-c", "cat < /dev/null > /dev/tcp/127.0.0.1/11434"]
  }

  labels {
    label = "traefik.http.services.ollama.loadbalancer.server.port"
    value = "11434"
  }

  networks_advanced {
    name = docker_network.ollama.id
  }

  volumes {
    container_path = "/etc/localtime"
    host_path      = "/etc/localtime"
    read_only      = true
  }

  volumes {
    container_path = "/root/.ollama"
    host_path      = "/mnt/dozer/apps/ollama/data"
    read_only      = false
  }

  volumes {
    container_path = "/ollama-models"
    host_path      = "/mnt/dozer/apps/ollama/models"
    read_only      = false
  }
}
