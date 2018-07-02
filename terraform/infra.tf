# Set the variable value in *.tfvars file
# or using -var="hcloud_token=..." CLI option
variable "hcloud_token" {}

# Configure the Hetzner Cloud Provider
provider "hcloud" {
    token = "${var.hcloud_token}"
}

resource "hcloud_ssh_key" "default" {
    name = "Terraform Deploy"
    public_key = "${file("~/.ssh/id_rsa.pub")}"
}

resource "hcloud_server" "k8s02_masters" {
    count = 3
    name = "k8s02-master${count.index+1}"
    server_type = "cx11" # use smallest instance with local storage for best master performance
    image = "fedora-28"
    datacenter = "fsn1-dc8"
    ssh_keys = ["${hcloud_ssh_key.default.name}"]
    keep_disk = false
    rescue = false
}

/*resource "hcloud_server" "ks802_workers" {
    count = 3
    name = "k8s02-worker${count.index+1}"
    server_type = "cx21" # use smallest instance with local storage for best master performance
    image = "fedora-28"
    datacenter = "fsn1-dc8"
    ssh_keys = ["${hcloud_ssh_key.default.name}"]
    keep_disk = false
    rescue = false
}*/

data "template_file" "ansible_inventory" {
    template = "${file("${path.module}/ansible_inventory.tpl")}"

    vars {
        masters_name = "${join(",", hcloud_server.k8s02_masters.*.name)}"
        masters_ipv4 = "${join(",", hcloud_server.k8s02_masters.*.ipv4_address)}"
        masters_datacenter = "${join(",", hcloud_server.k8s02_masters.*.datacenter)}"
        masters_server_type = "${join(",", hcloud_server.k8s02_masters.*.server_type)}"
    }
}

resource "local_file" "ansible_inventory" {
    content = "${data.template_file.ansible_inventory.rendered}"
    filename = "${path.module}/../ansible/inventory"
}
