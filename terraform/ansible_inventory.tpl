${join("\n", formatlist("%s ansible_host=%s datacenter=%s server_type=%s", split(",", masters_name), split(",", masters_ipv4), split(",", masters_datacenter), split(",", masters_server_type)))}
