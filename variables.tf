variable "ssh_key_private" {
  type = "string"
  default = "~/.ssh/id_rsa"
}

variable "hcloud_token" {
  type = "string"
}

variable "domain" {
  default = "example.com"
}

variable "cf_email" {
}

variable "cf_token" {
}

variable "master_instance_type" {
  type = "string"
  default = "cx11"
}

variable "master_count" {
    type = "string"
    default = 2
}

variable "worker_count" {
    type = "string"
    default = 0
}

# TODO Add config optinos for VMs
