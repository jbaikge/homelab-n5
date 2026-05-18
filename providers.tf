terraform {
  required_version = ">= 1.10.6"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "4.4.0"
    }

    sops = {
      source  = "carlpett/sops"
      version = "1.4.1"
    }
  }

  # https://developers.cloudflare.com/terraform/advanced-topics/remote-backend/
  backend "s3" {
    bucket                      = var.backend.bucket
    key                         = var.backend.key
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    access_key                  = var.backend.access_key
    secret_key                  = var.backend.secret_key
    endpoints                   = { s3 = var.backend.endpoint }
  }
}

provider "sops" {
}

provider "docker" {
  for_each = var.hosts
  alias    = "hosts"
  host     = each.value.provider_host
}
