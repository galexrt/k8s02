# TODO Make configurable
module "cloud_provider" {
  source = "${path.module}/clouds/hetzner"
}

data "template_file" "ansible_inventory" {
  template = "${file("${path.module}/ansible_inventory.tpl")}"

  vars {
    masters_name        = "${module.cloud_provider.masters_name}"
    masters_ipv4        = "${module.cloud_provider.masters_ipv4}"
    masters_ipv6        = "${module.cloud_provider.masters_ipv6}"
    masters_datacenter  = "${module.cloud_provider.masters_datacenter}"
    masters_server_type = "${module.cloud_provider.masters_server_type}"
  }
}

resource "local_file" "ansible_inventory" {
  content  = "${data.template_file.ansible_inventory.rendered}"
  filename = "${path.module}/../ansible/inventory"
}
