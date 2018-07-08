variable "cf_email" {}

variable "cf_token" {}

variable "ssh_key_private" {
  type = "string"
}

variable "dns_domain" {
  type = "string"
}

variable "common_name" {
  type = "string"
}

variable "names" {
  type = "list"
}

variable "addresses_ipv4" {
  type = "list"
}

variable "addresses_ipv6" {
  type = "list"
}
