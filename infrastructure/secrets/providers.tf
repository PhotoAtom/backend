terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.35.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
  }

  backend "kubernetes" {
    secret_suffix = "secrets.photoatom.backend"
  }
}

provider "kubernetes" {

}

provider "random" {

}

