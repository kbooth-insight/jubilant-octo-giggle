resource "azurerm_resource_group" "core" {
  name     = "${var.prefix}-core-rg"
  location = "${var.location}"

  tags = "${local.common_tags}"
}

module "core" {
  source                  = "./modules/core"
  resource_group_name     = "${azurerm_resource_group.core.name}"
  location                = "${var.location}"
  vnet_address_spacing    = "${var.vnet_address_spacing}"
  subnet_address_prefixes = "${var.subnet_address_prefixes}"
  public_key_openssh      = "${tls_private_key.main.public_key_openssh}"
  key_vault_object_ids    = "${var.key_vault_object_ids}"
  tags                    = "${local.common_tags}"
}

module "cluster_1" {
  source                    = "./modules/cv-cluster"
  cluster_name              = "c1"
  resource_group_name       = "${var.prefix}-cluster1-rg"
  location                  = "${var.location}"
  subnet_id                 = "${module.core.subnet-ids[0]}"
  network_security_group_id = "${module.core.network-security-group-id}"
  public_key_openssh        = "${tls_private_key.main.public_key_openssh}"
  consul_image_id           = "${var.consul_image_id}"
  vault_image_id            = "${var.vault_image_id}"
  tags                      = "${local.common_tags}"

  vault_id               = "${module.core.keyvault_id}"
  vault_name             = "${module.core.keyvault_name}"
  domain                 = "${var.domain}"
  consul_count           = "${var.consul_count}"
  vault_count            = "${var.vault_count}"
  consul_encrypt         = "${var.consul_encrypt}"
  vault_unseal_client_id = "${var.vault_unseal_client_id}"
}

# module "cluster_2" {
#   source                    = "./modules/cv-cluster"
#   cluster_name              = "c2"
#   resource_group_name       = "${var.prefix}-cluster2-rg"
#   location                  = "${var.location}"
#   subnet_id                 = "${module.core.subnet-ids[1]}"
#   network_security_group_id = "${module.core.network-security-group-id}"
#   public_key_openssh        = "${tls_private_key.main.public_key_openssh}"
#   consul_image_id           = "${var.consul_image_id}"
#   vault_image_id            = "${var.vault_image_id}"
#   tags                      = "${local.common_tags}"

#   vault_id               = "${module.core.keyvault_id}"
#   vault_name             = "${module.core.keyvault_name}"
#   domain                 = "${var.domain}"
#   consul_count           = "${var.consul_count}"
#   vault_count            = "${var.vault_count}"
#   consul_encrypt         = "${var.consul_encrypt}"
#   vault_unseal_client_id = "${var.vault_unseal_client_id}"
# }

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "echo \"${tls_private_key.main.private_key_pem}\" > azure-cvstack.pem"
  }

  provisioner "local-exec" {
    command = "chmod 600 azure-cvstack.pem"
  }
}
