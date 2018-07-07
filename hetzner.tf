# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "default" {
  name       = "Terraform Deploy"
  public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "masters" {
  count       = "${var.master_count}"
  name        = "k8s02-master${count.index+1}.${var.domain}"
  server_type = "${var.master_instance_type}"      # use smallest instance with local storage for masters
  image       = "fedora-28"
  datacenter  = "fsn1-dc8"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]
  keep_disk   = false

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install python curl salt-master salt-minion",
      "sudo salt-key --gen-keys=${self.name} --gen-keys-dir=/etc/salt/pki/minion --keysize=4096",
      "sudo mv /etc/salt/pki/minion/${self.name}.pem /etc/salt/pki/minion/minion.pem",
      "sudo mv /etc/salt/pki/minion/${self.name}.pub /etc/salt/pki/minion/minion.pub"
    ]
  }
}

resource "hcloud_server" "workers" {
  count       = "${var.worker_count}"
  name        = "k8s02-worker${count.index+1}.${var.domain}"
  server_type = "cx21"                             # use smallest instance with local storage for best master performance
  image       = "fedora-28"
  datacenter  = "fsn1-dc8"
  ssh_keys    = ["${hcloud_ssh_key.default.name}"]
  keep_disk   = false

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo dnf -y install python curl salt-master salt-minion",
      "sudo salt-key --gen-keys=${self.name} --gen-keys-dir=/etc/salt/pki/minion --keysize=4096",
      "sudo mv /etc/salt/pki/minion/${self.name}.pem /etc/salt/pki/minion/minion.pem",
      "sudo mv /etc/salt/pki/minion/${self.name}.pub /etc/salt/pki/minion/minion.pub"
    ]
  }
}
