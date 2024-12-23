// PostgreSQL Database Credentials for PhotoAtom Backend
data "kubernetes_secret" "photoatom_database_credentials" {
  metadata {
    name      = var.photoatom_database_credentials_name
    namespace = var.postgres_namespace
  }
}

resource "kubernetes_secret" "photoatom_database_secret" {
  metadata {
    name      = var.photoatom_database_secret_name
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  data = {
    "POSTGRES_USERNAME" = data.kubernetes_secret.photoatom_database_credentials.data["username"]
    "POSTGRES_PASSWORD" = data.kubernetes_secret.photoatom_database_credentials.data["password"]
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "photoatom_database_configurations" {
  metadata {
    name      = var.photoatom_database_configuration_name
    namespace = var.namespace
  }

  data = {
    "POSTGRES_HOST" = "${var.postgres_cluster_name}-rw.${var.postgres_namespace}.svc"
  }
}

data "kubernetes_secret" "database_certificate_authority" {
  metadata {
    name      = var.database_certificate_authority_name
    namespace = var.postgres_namespace
  }
}

data "kubernetes_secret" "database_ssl_certificates" {
  metadata {
    name      = var.database_ssl_certificates_name
    namespace = var.postgres_namespace
  }
}

resource "kubernetes_secret" "photoatom_database_ssl_certificates" {
  metadata {
    name      = var.photoatom_database_ssl_certificates_name
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  data = {
    "ca.crt"  = data.kubernetes_secret.database_certificate_authority.data["ca.crt"]
    "tls.crt" = data.kubernetes_secret.database_ssl_certificates.data["tls.crt"]
  }

  type = "Opaque"
}

resource "kubernetes_secret" "photoatom_database_ssl_key" {
  metadata {
    name      = var.photoatom_database_ssl_key_name
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  binary_data = {
    "tls.pk8" = "${filebase64("${path.module}/tls.pk8")}"
  }

  type = "Opaque"
}

// Valkey Database Certificates for PhotoAtom Backend
resource "kubernetes_secret" "valkey_certificates" {
  metadata {
    name      = var.photoatom_valkey_certs_name
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  binary_data = {
    "keystore.p12"   = "${filebase64("${path.module}/cache/keystore.p12")}"
    "truststore.jks" = "${filebase64("${path.module}/cache/truststore.jks")}"
  }

  lifecycle {
    ignore_changes = [binary_data]
  }

  type = "Opaque"
}

// Valkey Database Credentials for PhotoAtom Backend
data "kubernetes_secret" "valkey_password" {
  metadata {
    name      = "valkey"
    namespace = var.valkey_namespace
  }
}

resource "kubernetes_secret" "photoatom_valkey_secret" {
  metadata {
    name      = var.photoatom_valkey_secret_name
    namespace = var.namespace
    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  data = {
    VALKEY_PASSWORD = data.kubernetes_secret.valkey_password.data["valkey-password"]
  }

  type = "Opaque"
}

resource "kubernetes_config_map" "photoatom_valkey_configuration" {
  metadata {
    name      = var.photoatom_valkey_configuration_name
    namespace = var.namespace
    labels = {
      app       = "photoatom"
      component = "configmap"
    }
  }

  data = {
    VALKEY_HOST = "valkey-node-0.${var.valkey_namespace}.svc"
    VALKEY_PORT = 6379
  }
}

// Keycloak Configurations
resource "kubernetes_config_map" "photoatom_keycloak_configuration" {
  metadata {
    name      = var.photoatom_keycloak_configuration_name
    namespace = var.namespace
    labels = {
      app       = "photoatom"
      component = "configmap"
    }
  }

  data = {
    KEYCLOAK_URL = "${var.keycloak_host_name}.${var.photoatom_domain}"
  }
}
