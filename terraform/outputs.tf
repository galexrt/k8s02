output "masters_name" {
  value = "${module.cloud_provider.masters_name}"
}

output "masters_ipv4" {
  value = "${module.cloud_provider.masters_ipv4}"
}

output "masters_ipv6" {
  value = "${module.cloud_provider.masters_ipv6}"
}

output "masters_datacenter" {
  value = "${module.cloud_provider.masters_datacenter}"
}

output "masters_server_type" {
  value = "${module.cloud_provider.masters_server_type}"
}
