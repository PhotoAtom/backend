resource "random_password" "keystore_password" {
  length           = 16
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*"
  min_special      = 2
}

resource "random_password" "truststore_password" {
  length           = 16
  lower            = true
  numeric          = true
  special          = true
  override_special = "-_*"
  min_special      = 2
}


resource "kubernetes_secret" "valkey_certificates" {
  metadata {
    name      = var.photoatom_valkey_certificates_passwords_name
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  binary_data = {
    "VALKEY_CA_CERT_PASSWORD"   = random_password.truststore_password.result
    "VALKEY_USER_CERT_PASSWORD" = random_password.keystore_password.result
  }

  type = "Opaque"
}
