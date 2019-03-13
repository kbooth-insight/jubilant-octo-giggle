# output "private-ips" {
#   value = "${azurerm_network_interface.module.*.private_ip_address}"
# }

output "vmss_name" {
  value = "${azurerm_virtual_machine_scale_set.module.name}"
}
