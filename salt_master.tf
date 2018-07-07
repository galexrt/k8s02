resource "tls_private_key" "salt_masters" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "salt_masters" {
  key_algorithm   = "${tls_private_key.salt_masters.algorithm}"
  private_key_pem = "${tls_private_key.salt_masters.private_key_pem}"

  # Certificate expires after 12 hours.
  validity_period_hours = 48

  # Generate a new certificate if Terraform is run within three
  # hours of the certificate's expiration time.
  early_renewal_hours = 12

  # Reasonable set of uses for a server SSL certificate.
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]

  dns_names = ["${element(cloudflare_record.salt_masters_v4.*.hostname, 0)}", "${formatlist("%s.%s", hcloud_server.masters.*.name, var.domain)}"]
  ip_addresses = ["${hcloud_server.masters.*.ipv4_address}"]

  subject {
    common_name  = ""
    organization = "ACME Examples, Inc"
  }
}


resource "null_resource" "salt_master" {
    count = "${var.master_count}"

    # Changes to any master instance of the cluster requires re-provisioning of masters
    triggers {
      cluster_instance_ids = "${join(",", hcloud_server.masters.*.id)}"
      salt_files_sha256 = "${data.archive_file.salt.output_base64sha256}"
      salt_master_certs_sha256 = "${sha1(tls_private_key.salt_masters.private_key_pem)}"
    }

    # Bootstrap script can run on any instance of the cluster
    # So we just choose the first in this case
    connection {
      host        = "${element(hcloud_server.masters.*.ipv4_address, count.index)}"
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

    depends_on = [
      "hcloud_server.masters",
      "cloudflare_record.salt_masters_v4",
      "cloudflare_record.salt_masters_v6",
      "tls_self_signed_cert.salt_masters"
    ]
}
