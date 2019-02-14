output "virtualnetwork-ids" {
  value       = "${azurerm_virtual_network.module.id}"
  description = "Id of the Vnet"
}

output "subnet-ids" {
  value       = "${azurerm_subnet.module.*.id}"
  description = "Id's of the Subnets"
}

output "network-security-group-id" {
  value = "${azurerm_network_security_group.module.id}"
}

output "public-fqdn" {
  value = "${azurerm_public_ip.module.fqdn}"
}

output "keyvault_id" {
  value = "${azurerm_key_vault.main.id}"
}

output "keyvault_name" {
  value = "${azurerm_key_vault.main.name}"
}
