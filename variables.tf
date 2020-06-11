
variable do_token{}

variable "min_cluster_nodes" {
  type = number
  default = 1
 }

variable "max_cluster_nodes" {
  type = number
  default = 10
 }

variable "initial_node_count" {
  type = number
  default = 3
 }

variable "droplet_size" {
  type = string
  default = "s-1vcpu-2gb"
 }