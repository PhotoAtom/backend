// Certificate Passwords
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


resource "kubernetes_secret" "certificate_passwords" {
  metadata {
    name      = "photoatom-certificate-passwords"
    namespace = var.namespace

    labels = {
      app       = "photoatom"
      component = "secret"
    }
  }

  binary_data = {
    "SSL_CA_CERTIFICATE_PASSWORD" = base64encode(random_password.truststore_password.result)
    "SSL_CERTIFICATE_PASSWORD"    = base64encode(random_password.keystore_password.result)
  }

  type = "Opaque"
}


// Certificate Authority to be used with PhotoAtom Backend
resource "kubernetes_manifest" "photoatom_ca" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "${var.photoatom_ca_name}"
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = "photoatom"
        "component" = "ca"
      }
    }
    "spec" = {
      "isCA" = true
      "subject" = {
        "organizations"       = ["photoatom"]
        "countries"           = ["India"]
        "organizationalUnits" = ["backend"]
      }
      "commonName" = "photoatom-ca"
      "secretName" = "photoatom-ca-tls"
      "duration"   = "70128h"
      "privateKey" = {
        "algorithm" = "ECDSA"
        "size"      = 256
      }
      "issuerRef" = {
        "name"  = "${var.cluster_issuer_name}"
        "kind"  = "ClusterIssuer"
        "group" = "cert-manager.io"
      }
    }
  }
}

// Issuer for the PhotoAtom Backend Namespace
resource "kubernetes_manifest" "photoatom_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "${var.photoatom_issuer_name}"
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = "photoatom"
        "component" = "issuer"
      }
    }
    "spec" = {
      "ca" = {
        "secretName" = "photoatom-ca-tls"
      }
    }
  }

  depends_on = [kubernetes_manifest.photoatom_ca]
}

// Certificate for PhotoAtom Backend
resource "kubernetes_manifest" "photoatom_certificate" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "${var.photoatom_certificate_name}"
      "namespace" = "${var.namespace}"
      "labels" = {
        "app"       = "photoatom"
        "component" = "certificate"
      }
    }
    "spec" = {
      "dnsNames" = [
        "${var.host_name}.${var.photoatom_domain}",
        "localhost",
        "127.0.0.1",
        "*.backend.svc.cluster.local",
        "photoatom",
        "photoatom.backend.svc.cluster.local",
        "*.photoatom.backend.svc.cluster.local",
      ]
      "subject" = {
        "organizations"       = ["photoatom"]
        "countries"           = ["India"]
        "organizationalUnits" = ["backend"]
      }
      "commonName" = "photoatom"
      "secretName" = "photoatom-tls"
      "issuerRef" = {
        "name" = "${var.photoatom_issuer_name}"
      }
      "keystores" = {
        "jks" = {
          "create" : true
          "passwordSecretRef" : {
            "name" : "photoatom-certificate-passwords"
            "key" : "jksPassword"
          }
          "alias" : "backend"
        }
        "pkcs12" : {
          "create" : true
          "passwordSecretRef" : {
            "name" : "photoatom-certificate-passwords"
            "key" : "pkcs12Password"
          }
        }
      }
    }
  }

  depends_on = [kubernetes_manifest.photoatom_issuer]
}

// Kubernetes Secret for Cloudflare Tokens
resource "kubernetes_secret" "cloudflare_token" {
  metadata {
    name      = "cloudflare-token"
    namespace = var.namespace
    labels = {
      "app"       = "photoatom"
      "component" = "secret"
    }

  }

  data = {
    cloudflare-token = var.cloudflare_token
  }

  type = "Opaque"
}

// Cloudflare Issuer for photoatom Ingress Service
resource "kubernetes_manifest" "photoatom_public_issuer" {
  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Issuer"
    "metadata" = {
      "name"      = "photoatom-public-issuer"
      "namespace" = var.namespace
      "labels" = {
        "app"       = "photoatom"
        "component" = "issuer"
      }
    }
    "spec" = {
      "acme" = {
        "email"  = var.cloudflare_email
        "server" = "https://acme-v02.api.letsencrypt.org/directory"
        "privateKeySecretRef" = {
          "name" = "photoatom-issuer-key"
        }
        "solvers" = [
          {
            "dns01" = {
              "cloudflare" = {
                "email" = var.cloudflare_email
                "apiTokenSecretRef" = {
                  "name" = "cloudflare-token"
                  "key"  = "cloudflare-token"
                }
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [kubernetes_secret.cloudflare_token]
}

// Certificate to be used for photoatom Ingress
resource "kubernetes_manifest" "photoatom_ingress_certificate" {

  manifest = {
    "apiVersion" = "cert-manager.io/v1"
    "kind"       = "Certificate"
    "metadata" = {
      "name"      = "photoatom-ingress-certificate"
      "namespace" = var.namespace
      "labels" = {
        "app"       = "photoatom"
        "component" = "certificate"
      }
    }
    "spec" = {
      "duration"    = "2160h"
      "renewBefore" = "360h"
      "subject" = {
        "organizations"       = ["photoatom"]
        "countries"           = ["India"]
        "organizationalUnits" = ["photoatom"]
      }
      "privateKey" = {
        "algorithm" = "RSA"
        "encoding"  = "PKCS1"
        "size"      = "2048"
      }
      "dnsNames"   = ["${var.host_name}.${var.photoatom_domain}"]
      "secretName" = "photoatom-ingress-tls"
      "issuerRef" = {
        "name"  = "photoatom-public-issuer"
        "kind"  = "Issuer"
        "group" = "cert-manager.io"
      }
    }
  }

  depends_on = [kubernetes_manifest.photoatom_public_issuer]

}
