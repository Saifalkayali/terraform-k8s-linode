resource "local_file" "kubeconfig" {
  depends_on = [linode_lke_cluster.saif-k8s-lke-cluster]
  filename   = "kube-config"
  content    = base64decode(linode_lke_cluster.saif-k8s-lke-cluster.kubeconfig)
}