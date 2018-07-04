provisioner "remote-exec" {
  inline = ["sudo dnf -y install python curl"]

  connection {
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }
}

provisioner "local-exec" {
  command = "ansible-playbook -u root -i '${self.public_ip},' --private-key ${var.ssh_key_private} provision.yml"
}
