 provider digitalocean{
  token = var.do_token
}

provider "kubernetes" {
  load_config_file = false
  host  = digitalocean_kubernetes_cluster.k8s-cluster.endpoint
  token = digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].cluster_ca_certificate
  )
}

#provider "helm" {
#  kubernetes {
#    host     = digitalocean_kubernetes_cluster.foo.endpoint
#
#    client_certificate     = file("~/.kube/client-cert.pem")
#    client_key             = file("~/.kube/client-key.pem")
#    cluster_ca_certificate = base64decode(
#    digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].cluster_ca_certificate
#    )
#  }
#}