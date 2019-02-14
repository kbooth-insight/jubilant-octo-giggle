output "consul-ips" {
  value = "${module.consul_cluster.private-ips}"
}

output "vault-ips" {
  value = "${module.vault_cluster.private-ips}"
}
