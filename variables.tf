variable "backend" {
  description = "Configuration values for CloudFlare S3 state backend"

  type = object({
    bucket     = string
    key        = string
    endpoint   = string
    access_key = string
    secret_key = string
  })
}

variable "hosts" {
  description = "Map of host short-name to various config options"

  type = map(object({
    provider_host = string
    service_ip    = string
  }))
}

variable "apps" {
  description = "Map of services to host keys in the hosts var"

  type = object({
    adminer        = string
    bentopdf       = string
    birdnet_go     = string
    blocky         = list(string)
    cloudflared    = list(string)
    databasus      = string
    dozzle         = string
    dozzle_agent   = list(string)
    forgejo        = string
    glance         = string
    gotenberg      = string
    home_assistant = string
    homebox        = string
    it_tools       = string
    librespeed     = string
    linkding       = string
    miniflux       = string
    mysql          = string
    omni_tools     = string
    openspeedtest  = string
    paperless_ngx  = string
    postgres       = string
    prometheus     = string
    redis          = string
    tika           = string
    traefik        = list(string)
    unbound        = list(string)
    wakapi         = string
    zwave          = string
  })
}
