terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.27.1"
    }
  }
}

provider "linode" {
}

resource "linode_lke_cluster" "saif-k8s-lke-cluster" {
  label       = "cluster"
  k8s_version = "1.21"
  region      = "us-central"
  tags        = ["dev","saif-k8s-lke-cluster","us-central"]

  pool {
    type  = "g6-standard-2"
    count = 3
  }
}