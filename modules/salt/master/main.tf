resource "tls_private_key" "salt_masters" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "salt_masters" {
  key_algorithm   = "${tls_private_key.salt_masters.algorithm}"
  private_key_pem = "${tls_private_key.salt_masters.private_key_pem}"

  # Certificate expires after 12 hours.
  validity_period_hours = 168

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 48

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names    = ["${var.common_name}.${var.dns_domain}", "${formatlist("%s.%s", var.names, var.dns_domain)}"]
  ip_addresses = ["${concat(var.addresses_ipv4, var.addresses_ipv6)}"]

  subject {
    common_name  = "${var.common_name}.${var.dns_domain}"
    organization = "K8S02"
  }
}

resource "null_resource" "salt_master_cert" {
  count = "${length(var.names)}"

  triggers {
    cluster_instance_ids     = "${join(",", var.names)}"
    salt_master_certs_sha256 = "${sha1(tls_private_key.salt_masters.private_key_pem)}"
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host        = "${element(var.addresses_ipv4, count.index)}"
    type        = "ssh"
    user        = "root"
    private_key = "${file(var.ssh_key_private)}"
  }

  provisioner "remote-exec" {
    inline = ["sudo mkdir -p /etc/salt/ssl"]
  }

  provisioner "file" {
    content     = "${tls_private_key.salt_masters.private_key_pem}"
    destination = "/etc/salt/ssl/salt.key"
  }

  provisioner "file" {
    content     = "${tls_self_signed_cert.salt_masters.cert_pem}"
    destination = "/etc/salt/ssl/salt.crt"
  }
}

module "salt_master_dns" {
  source = "./../../dns/cloudflare"

  cf_email       = "${var.cf_email}"
  cf_token       = "${var.cf_token}"
  domain         = "${var.dns_domain}"
  names          = ["${var.common_name}.${var.dns_domain}"]
  addresses_ipv4 = "${var.addresses_ipv4}"
  addresses_ipv6 = "${var.addresses_ipv6}"
  proxied        = "false"
}
