data "template_file" "saltify_master_map" {
  template = <<EOF
  - $${name}:
      ssh_host: $${ipv4_address}
      ssh_username: root
      key_filename: ${var.ssh_key_private}
EOF
  count = "${var.master_count}"
  vars {
    name = "${element(hcloud_server.masters.*.name, count.index)}"
    ipv4_address = "${element(hcloud_server.masters.*.ipv4_address, count.index)}"
  }
}

resource "local_file" "saltify_master_map" {
  content = <<EOF
salt-this-machine:
${join("", data.template_file.saltify_master_map.*.rendered)}
EOF
  filename = "saltify_master_map"
}
/*
resource "null_resource" "saltify" {
  triggers {
    cluster_instance_ids = "${join(",", hcloud_server.masters.*.id, hcloud_server.workers.*.id)}"
  }

  connection {
    host = "${element(concat(hcloud_server.masters.*.ipv4_address, hcloud_server.workers.*.ipv4_address), count.index)}"
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "local-exec" {
      inline = ["sudo salt-cloud saltify_map"]
  }

  depends_on = [
    "template_file.saltify_master_map",
    "template_file.saltify_worker_map"
  ]
}*/
