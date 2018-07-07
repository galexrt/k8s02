resource "null_resource" "kubernetes_masters" {
  count = "${var.master_count}"

  # Changes to any master instance of the cluster requires re-provisioning of masters
  triggers {
    cluster_instance_ids = "${join(",", hcloud_server.masters.*.id)}"
    salt_sha256 = "${data.archive_file.salt.output_base64sha256}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(hcloud_server.masters.*.ipv4_address, count.index)}"
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "salt-masterless" {
    local_state_tree = "./salt"
    skip_bootstrap = true
    remote_state_tree = "/srv/salt"
  }

  depends_on = [
    "null_resource.salt_master"
  ]
}

resource "null_resource" "kubernetes_workers" {
  count = "${length(hcloud_server.workers.*.id)}"

  # Changes to any master instance of the cluster requires re-provisioning of masters
  triggers {
    cluster_instance_ids = "${join(",", hcloud_server.workers.*.id)}"
    salt_sha256 = "${sha1(file(data.archive_file.salt.output_base64sha256))}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(hcloud_server.workers.*.ipv4_address, count.index)}"
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "remote-exec" {
      inline = ["sudo mkdir -p /etc/salt/ssl"]
  }
  provisioner "file" {
    content = "${tls_private_key.salt_masters.private_key_pem}"
    destination = "/etc/salt/ssl/salt-master.key"
  }
  provisioner "file" {
    content = "${tls_self_signed_cert.salt_masters.cert_pem}"
    destination = "/etc/salt/ssl/salt-master.crt"
  }

  provisioner "salt-masterless" {
    local_state_tree = "./salt"
    skip_bootstrap = true
    remote_state_tree = "/srv/salt"
  }

  depends_on = [
    "hcloud_server.workers",
    "cloudflare_record.salt_masters_v4",
    "cloudflare_record.salt_masters_v6",
    "null_resource.kubernetes_masters"
  ]
}

// Run salt "one last time" fater cluster provisioning has been done
resource "null_resource" "cluster" {
  count = "${var.master_count + var.worker_count}"

  # Changes to any instance of the cluster requires re-provisioning
  triggers {
    cluster_instance_ids = "${join(",", hcloud_server.masters.*.id, hcloud_server.workers.*.id)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = "${element(concat(hcloud_server.masters.*.ipv4_address, hcloud_server.workers.*.ipv4_address), count.index)}"
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "salt-masterless" {
    local_state_tree = "./salt"
    skip_bootstrap = true
    remote_state_tree = "/srv/salt"
    #custom_state = "kubernetes-check"
  }

  depends_on = [
    "null_resource.kubernetes_masters",
    "null_resource.kubernetes_workers"
  ]
}
