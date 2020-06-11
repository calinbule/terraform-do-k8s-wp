
 data "digitalocean_ssh_key" "terraform-do" {
  name = "terraform-do" 
 }



resource "digitalocean_vpc" "k8s-vpc" {
  name     = "k8s-vpc"
  region   = "fra1"
}


resource "digitalocean_kubernetes_cluster" "k8s-cluster" {
  name    = "k8s-cluster"
  region  = "fra1"
  version = "1.17.5-do.0"
  tags    = ["development"]
  vpc_uuid = digitalocean_vpc.k8s-vpc.id

  node_pool {
    name       = "k8s-cluster-worker-pool"
    size       = var.droplet_size
    node_count = var.initial_node_count
    auto_scale = true
    min_nodes  = var.min_cluster_nodes
    max_nodes  = var.max_cluster_nodes
  }
}


resource "digitalocean_loadbalancer" "k8s-load-balancer" {
  name = "k8s-load-balancer"
  region = "fra1"
  vpc_uuid = digitalocean_vpc.k8s-vpc.id

  forwarding_rule {
    entry_port = 80
    entry_protocol = "http"

    target_port = 80
    target_protocol = "http"
  }

  healthcheck {
    port = 22
    protocol = "tcp"
  }

  droplet_ids = digitalocean_kubernetes_cluster.k8s-cluster.node_pool.0.nodes[*].droplet_id
}


resource "digitalocean_project" "k8s" {
  name        = "k8s"
  description = "An auto-scalable kubernetes cluster"
  purpose     = "Web Application"
  environment = "Development"
}


resource "digitalocean_project_resources" "k8s-resources" {
  project = digitalocean_project.k8s.id
  resources = [digitalocean_loadbalancer.k8s-load-balancer.urn]
}

#resource "helm_release" "wordpress" {
#  name  = "wordpress"
#  chart = "bitnami/wordpress"
#}




output "k8s-resources-out-1" {
    value = digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].cluster_ca_certificate
}


output "k8s-resources-out-2" {
    value = digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0]
}


#output "k8s-resources-out-1" {
#    value = digitalocean_kubernetes_cluster.k8s-cluster.kube_config[0].cluster_ca_certificate
#}



