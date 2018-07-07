output "masters_name" {
  value = "${join(",", hcloud_server.masters.*.name)}"
}

output "masters_ipv4" {
  value = "${join(",", hcloud_server.masters.*.ipv4_address)}"
}

output "masters_ipv6" {
  value = "${join(",", hcloud_server.masters.*.ipv6_address)}"
}

output "masters_datacenter" {
  value = "${join(",", hcloud_server.masters.*.datacenter)}"
}

output "masters_server_type" {
  value = "${join(",", hcloud_server.masters.*.server_type)}"
}
