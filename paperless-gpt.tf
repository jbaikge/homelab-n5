resource "docker_image" "paperless_gpt" {
  provider     = docker.hosts[var.apps.paperless_gpt]
  name         = "ghcr.io/icereed/paperless-gpt:v0.25.1"
  keep_locally = false
}

# Ref: https://technotim.com/posts/paperless-ngx-local-ai/
# Ref: https://github.com/Foundry81/ollama-rocm-n5pro/blob/main/docker-compose.yml
resource "docker_container" "paperless_gpt" {
  provider = docker.hosts[var.apps.paperless_gpt]
  name     = "paperless-gpt"
  hostname = "paperless-gpt"
  image    = docker_image.paperless_gpt.image_id
  restart  = local.restart

  env = [
    "PAPERLESS_BASE_URL=http://paperless-ngx:8000",
    "PAPERLESS_API_TOKEN=${data.sops_file.secrets.data["paperless.token"]}",
    "PAPERLESS_PUBLIC_URL=https://docs.${data.sops_file.secrets.data["domain.tld"]}",

    "LLM_PROVIDER=ollama",
    "LLM_MODEL=llama3.2:3b",
    "OLLAMA_HOST=http://ollama:11434",
    "OLLAMA_CONTEXT_LENGTH=8192", # Sets Ollama NumCtx (context window)
    "TOKEN_LIMIT=1000",           # Recommended for smaller models

    "LLM_LANGUAGE=English", # Optional, default: English

    "OCR_PROVIDER=llm",              # Default OCR provider
    "VISION_LLM_PROVIDER=ollama",    # openai, ollama, mistral, or anthropic
    "VISION_LLM_MODEL=minicpm-v:8b", # minicpm-v (ollama) or gpt-4o (openai) or claude-sonnet-4-5 (anthropic/claude)

    "AUTO_OCR_TAG=paperless-gpt-ocr-auto",
    "AUTO_TAG=paperless-gpt-auto",
    "MANUAL_TAG=paperless-gpt-manual",
    "PDF_OCR_TAGGING=true",
    "PDF_OCR_COMPLETE_TAG=paperless-gpt-ocr-complete",
    "PDF_UPLOAD=false",

    "LOG_LEVEL=INFO", # INFO DEBUG
  ]

  depends_on = [
    docker_container.paperless_ngx,
    docker_container.ollama,
  ]

  labels {
    label = "traefik.enable"
    value = "true"
  }

  labels {
    label = "traefik.http.routers.paperless_gpt.rule"
    value = "Host(`paperless-gpt.${data.sops_file.secrets.data["domain.tld"]}`)"
  }

  labels {
    label = "traefik.http.routers.paperless_gpt.entrypoints"
    value = "websecure"
  }

  labels {
    label = "traefik.http.services.paperless_gpt.loadbalancer.server.port"
    value = "8080"
  }

  networks_advanced {
    name = docker_network.paperless.id
  }

  networks_advanced {
    name = docker_network.traefik[var.apps.paperless_ngx].id
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
    container_path = "/app/prompts"
    host_path      = "/mnt/tank/apps/paperless/prompts"
    read_only      = false
  }
}
