terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
  }

  backend "kubernetes" {
    secret_suffix = "configuration.photoatom.backend"
  }
}

provider "kubernetes" {

}

provider "null" {

}

