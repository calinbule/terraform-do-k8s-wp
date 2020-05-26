
variable do_token{}

variable "min_cluster_nodes" {
  type = number
  default = 1
 }

variable "max_cluster_nodes" {
  type = number
  default = 10
 }

variable "droplet_size" {
  type = string
  default = "s-2vcpu-2gb"
 }



 data "digitalocean_ssh_key" "terraform-do" {
  name = "terraform-do" 
 }



 provider digitalocean{
  token = var.do_token
}

#provider "kubernetes" {
#  load_config_file = false
#  host  = digitalocean_kubernetes_cluster.foo.endpoint
#  token = digitalocean_kubernetes_cluster.foo.kube_config[0].token
#  cluster_ca_certificate = base64decode(
#    digitalocean_kubernetes_cluster.foo.kube_config[0].cluster_ca_certificate
#  )
#}



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
    size       = "s-1vcpu-2gb"
    node_count = 3
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 10
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
  description = "A scalable "
  purpose     = "Web Application"
  environment = "Development"
  resources   = concat(
    digitalocean_kubernetes_cluster.k8s-cluster.node_pool.0.nodes[*].droplet_id,
    [digitalocean_loadbalancer.k8s-load-balancer.urn]
    )
}

