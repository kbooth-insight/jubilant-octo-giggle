resource "azurerm_resource_group" "cluster" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"

  tags = "${var.tags}"
}

module "consul_cluster" {
  source                    = "../../modules/consul"
  name                      = "consul${var.cluster_name}"
  resource_group_name       = "${azurerm_resource_group.cluster.name}"
  location                  = "${var.location}"
  subnet_id                 = "${var.subnet_id}"
  network_security_group_id = "${var.network_security_group_id}"
  public_key_openssh        = "${var.public_key_openssh}"
  os_image_id               = "${var.consul_image_id}"
  tags                      = "${var.tags}"

  vault_id       = "${var.vault_id}"
  domain         = "${var.domain}"
  count          = "${var.consul_count}"
  consul_encrypt = "${var.consul_encrypt}"
}

module "vault_cluster" {
  source                    = "../../modules/vault"
  name                      = "vault${var.cluster_name}"
  resource_group_name       = "${azurerm_resource_group.cluster.name}"
  location                  = "${var.location}"
  subnet_id                 = "${var.subnet_id}"
  network_security_group_id = "${var.network_security_group_id}"
  public_key_openssh        = "${var.public_key_openssh}"
  os_image_id               = "${var.vault_image_id}"
  tags                      = "${var.tags}"

  vault_id               = "${var.vault_id}"
  vault_name             = "${var.vault_name}"
  vault_unseal_client_id = "${var.vault_unseal_client_id}"
  domain                 = "${var.domain}"

  # pass in consul cluster addresses
  count          = "${var.vault_count}"
  consul_encrypt = "${var.consul_encrypt}"
  consul_nodes   = "${join(",", formatlist("\"%s\"", module.consul_cluster.private-ips))}"
}
