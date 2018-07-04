# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "default" {
  name       = "Terraform Deploy"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "k8s02_masters" {
  count       = "${var.master_count}"
  name        = "k8s02-master${count.index+1}"
  server_type = "${var.master_instance_type}"      # use smallest instance with local storage for masters
  image       = "fedora-28"
  datacenter  = "fsn1-dc8"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]
  keep_disk   = false
  rescue      = false
}

// If you want VM workers uncomment this resource
resource "hcloud_server" "ks802_workers" {
  count       = "${var.worker_count}"
  name        = "k8s02-worker${count.index+1}"
  server_type = "cx21"                             # use smallest instance with local storage for best master performance
  image       = "fedora-28"
  datacenter  = "fsn1-dc8"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]
  keep_disk   = false
  rescue      = false
}
