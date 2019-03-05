# Cluster 1
resource "azurerm_resource_group" "cluster1" {
  name     = "${var.prefix}-cluster1-rg"
  location = "${var.location}"
  tags     = "${local.common_tags}"
}

module "consul_cluster1" {
  source                    = "./modules/consul"
  name                      = "consulcl1"
  resource_group_name       = "${azurerm_resource_group.cluster1.name}"
  location                  = "${azurerm_resource_group.cluster1.location}"
  subnet_id                 = "${module.core.subnet-ids[0]}"
  network_security_group_id = "${module.core.network-security-group-id}"
  public_key_openssh        = "${tls_private_key.main.public_key_openssh}"
  os_image_id               = "${var.os_image_id}"
  tags                      = "${local.common_tags}"

  vault_id       = "${module.core.keyvault_id}"
  domain         = "${var.domain}"
  count          = "${var.consul_count}"
  consul_encrypt = "${var.consul_encrypt}"
}

module "vault_cluster1" {
  source                    = "./modules/vault"
  name                      = "vaultcl1"
  resource_group_name       = "${azurerm_resource_group.cluster1.name}"
  location                  = "${azurerm_resource_group.cluster1.location}"
  subnet_id                 = "${module.core.subnet-ids[0]}"
  network_security_group_id = "${module.core.network-security-group-id}"
  public_key_openssh        = "${tls_private_key.main.public_key_openssh}"
  os_image_id               = "${var.os_image_id}"
  tags                      = "${local.common_tags}"

  vault_id               = "${module.core.keyvault_id}"
  vault_name             = "${module.core.keyvault_name}"
  vault_unseal_client_id = "${var.vault_unseal_client_id}"
  domain                 = "${var.domain}"

  # pass in consul cluster addresses
  count          = "${var.vault_count}"
  consul_encrypt = "${var.consul_encrypt}"
  consul_nodes   = "${join(",", formatlist("\"%s\"", module.consul_cluster1.private-ips))}"
}

output "consul_cluster1-ips" {
  value = "${module.consul_cluster1.private-ips}"
}

output "vault-cluster1-ips" {
  value = "${module.vault_cluster1.private-ips}"
}
