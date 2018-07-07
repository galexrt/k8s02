provider "cloudflare" {
  email = "${var.cf_email}"
  token = "${var.cf_token}"
}

resource "cloudflare_record" "salt_masters_v4" {
  count   = "${var.master_count}"
  domain  = "${var.domain}"
  value   = "${element(hcloud_server.masters.*.ipv4_address, count.index)}"
  name    = "k8s02-salt-masters"
  type    = "A"
  proxied = false

  depends_on = ["hcloud_server.masters"]
}

resource "cloudflare_record" "salt_masters_v6" {
  count   = "${var.master_count}"
  domain  = "${var.domain}"
  value   = "${element(hcloud_server.masters.*.ipv6_address, count.index)}"
  name    = "k8s02-salt-masters"
  type    = "AAAA"
  proxied = false

  depends_on = ["hcloud_server.masters"]
}
