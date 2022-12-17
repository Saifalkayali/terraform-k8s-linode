terraform {
  required_providers {
    linode = {
      source = "linode/linode"
      version = "1.29.4"
    }
  }
}
//Use the Linode Provider
provider "linode" {
  token = var.token
}

//Use the linode_lke_cluster resource to create
//a Kubernetes cluster
resource "linode_lke_cluster" "saifk8s" {
    k8s_version = var.k8s_version
    label = var.label
    region = var.region
    tags = var.tags

    dynamic "pool" {
        for_each = var.pools
        content {
            type  = pool.value["type"]
            count = pool.value["count"]
        }
    }
}

//Export this cluster's attributes
output "kubeconfig" {
   value = linode_lke_cluster.saifk8s.kubeconfig
   sensitive = true
}

output "api_endpoints" {
   value = linode_lke_cluster.saifk8s.api_endpoints
}

output "status" {
   value = linode_lke_cluster.saifk8s.status
}

output "id" {
   value = linode_lke_cluster.saifk8s.id
}

output "pool" {
   value = linode_lke_cluster.saifk8s.pool
}

// Setting up Linode Object Storage as a Terraform backend
data "linode_object_storage_cluster" "primary" {
  id = "us-east-1"
}

resource "linode_object_storage_bucket" "saif-tf-state" {
  cluster = data.linode_object_storage_cluster.primary.id
  label   = "saif-tf-state"
}
    