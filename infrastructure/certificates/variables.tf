variable "namespace" {
  default     = "photoatom"
  description = "Namespace to be used for deploying PhotoAtom Backend and related resources."
}

variable "cluster_issuer_name" {
  default     = "photoatom-self-signed-issuer"
  description = "Name for the Cluster Issuer"
}

variable "photoatom_ca_name" {
  default     = "photoatom-ca-certificate"
  description = "Name for the Certificate Authority for PhotoAtom Backend"
}

variable "photoatom_issuer_name" {
  default     = "photoatom-ca-issuer"
  description = "Name for the Issuer for PhotoAtom Backend"
}

variable "photoatom_certificate_name" {
  default     = "photoatom-certificate"
  description = "Name for the certificate for PhotoAtom Backend"
}

variable "cloudflare_email" {
  description = "Email Address to be used for DNS Challenge"
  type        = string
  sensitive   = true
}

variable "cloudflare_token" {
  description = "Token to be used for DNS Challenge"
  type        = string
  sensitive   = true
}

variable "host_name" {
  default     = "backend"
  description = "Host name to be used with PhotoAtom Backend Ingress"
}

variable "photoatom_domain" {
  description = "Domain to be used for Ingress"
  default     = ""
  type        = string
}

