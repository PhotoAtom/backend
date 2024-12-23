variable "namespace" {
  default     = "backend"
  description = "Namespace to be used for deploying PhotoAtom Backend and related resources."
}


// PostgreSQL Variables
variable "postgres_namespace" {
  default     = "postgres"
  description = "Namespace to be used for deploying Postgres Cluster and related resources."
}

variable "photoatom_database_credentials_name" {
  default     = "photoatom-database-credentials"
  description = "Database Credentials Secret Name for PhotoAtom"
}

variable "postgres_cluster_name" {
  default     = "postgresql-cluster"
  description = "Name for the PostgreSQL Cluster Name"
}

variable "photoatom_database_secret_name" {
  default     = "photoatom-database-secret"
  description = "Database Credentials Secret Name for PhotoAtom"
}

variable "photoatom_database_configuration_name" {
  default     = "photoatom-database-configuration"
  description = "Database Configuration Name for PhotoAtom"
}

variable "database_certificate_authority_name" {
  default     = "postgresql-cluster-ca"
  description = "PostgreSQL Database Certificate Authority Details"
}

variable "database_ssl_certificates_name" {
  default     = "photoatom-pg-cert"
  description = "PostgreSQL Database SSL Certificate Details for PhotoAtom"
}

variable "photoatom_database_ssl_certificates_name" {
  default     = "photoatom-postgresql-ssl-certificates"
  description = "PostgreSQL Database SSL Certificate Details for PhotoAtom"
}

variable "photoatom_database_ssl_key_name" {
  default     = "photoatom-postgresql-ssl-key"
  description = "PostgreSQL Database SSL Key Details for PhotoAtom"
}

// Valkey Variables
variable "valkey_namespace" {
  default     = "valkey"
  description = "Namespace to be used for deploying Valkey Cluster and related resources."
}

variable "photoatom_valkey_certs_name" {
  default     = "photoatom-valkey-certs"
  description = "value"
}

variable "photoatom_valkey_secret_name" {
  default     = "photoatom-valkey-secret"
  description = "Valkey Credentials Secret Name for PhotoAtom"
}

variable "photoatom_valkey_configuration_name" {
  default     = "photoatom-valkey-configuration"
  description = "Valkey Configuration Name for PhotoAtom"
}

// Keycloak Variables
variable "keycloak_host_name" {
  default     = "auth"
  description = "Host name to be used with Keycloak Ingress"
}

variable "photoatom_domain" {
  description = "Domain to be used for Ingress"
  default     = ""
  type        = string
}

variable "photoatom_keycloak_configuration_name" {
  default     = "photoatom-keycloak-configuration"
  description = "PhotoAtom Configuration Name for PhotoAtom"
}
