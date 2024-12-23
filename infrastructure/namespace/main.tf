resource "kubernetes_namespace" "backend" {
  metadata {
    name = var.namespace
    labels = {
      app       = "backend"
      component = "namespace"
    }
  }
}
