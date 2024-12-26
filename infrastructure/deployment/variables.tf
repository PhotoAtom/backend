// Keycloak Variables
variable "keycloak_namespace" {
  default     = "keycloak"
  description = "Keycloak Namespace from where Ingress IP addresses are needed to be injected in pods."
}

variable "keycloak_ingress_name" {
  default     = "keycloak-ingress"
  description = "Keycloak Ingress Name whose IP are needed to be injected in pods."
}

variable "keycloak_host_name" {
  default     = "auth"
  description = "Host name to be used with Keycloak Ingress"
}

variable "photoatom_domain" {
  description = "Domain to be used for Ingress"
  default     = ""
  type        = string
}

// Secrets and Configmaps for mounting on the container
variable "namespace" {
  default     = "backend"
  description = "Namespace to be used for deploying PhotoAtom Backend and related resources."
}

variable "environment_variables_secrets_name" {
  default     = ["photoatom-certificate-passwords", "photoatom-database-secret", "photoatom-valkey-secret", "valkey-certificates-passwords"]
  description = "Environment Variables to be set on the container from Secrets."
}

variable "environment_variables_configmaps_name" {
  default     = ["photoatom-database-configuration", "photoatom-keycloak-configuration", "photoatom-valkey-configuration"]
  description = "Environment Variables to be set on the container from ConfigMaps."

}

variable "path_environment_variables" {
  default = [
    {
      name = "VALKEY_CA_CERT_PATH"
      path = "/mnt/certs/valkey/truststore.jks"
    },

    {
      name = "VALKEY_USER_CERT_PATH"
      path = "/mnt/certs/valkey/keystore.p12"
    },

    {
      name = "PSQL_CA_CERT_PATH"
      path = "/mnt/certs/database/ca.crt"
    },

    {
      name = "PSQL_USER_CERT_PATH"
      path = "/mnt/certs/database/tls.crt"
    },

    {
      name = "PSQL_USER_CERT_KEY_PATH"
      path = "/mnt/certs/database/key/tls.pk8"
    },

    {
      name = "SSL_CERTIFICATE_PATH"
      path = "/mnt/certs/tls/keystore.p12"
    },


  ]

  description = "Paths to be used for referencing files"

}

variable "mounted_secrets_name" {
  default = [
    {
      "secretName" = "photoatom-tls"
      "mountPath"  = "/mnt/certs/tls"
    },
    {
      "secretName" = "photoatom-postgresql-ssl-certificates"
      "mountPath"  = "/mnt/certs/database"
    },
    {
      "secretName" = "photoatom-postgresql-ssl-key"
      "mountPath"  = "/mnt/certs/database/key"
    },
    {
      "secretName" = "photoatom-valkey-certs"
      "mountPath"  = "/mnt/certs/valkey"
    },
  ]
  description = "Secrets to be mounted as part of the filesystem."
}

// Version for the artifact
variable "artifact_version" {
  description = "Artifact Version to be deployed"
  type        = string
}

// Ingress Variables
variable "backend_host_name" {
  description = "Host name for the PhotoAtom Backend"
  default     = "backend"
}
