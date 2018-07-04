variable "hcloud_token" {
  type = "string"
}

variable "master_instance_type" {
  type = "string"
  default = "cx11"
}

variable "master_count" {
    type = "integer"
    default = 3
}

variable "worker_count" {
    type = "integer"
    default = 0
}

# TODO Add config optinos for VMs
