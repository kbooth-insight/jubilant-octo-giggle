# Core Infrastructure
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

resource "tls_private_key" "main" {
  algorithm = "RSA"
}

resource "local_file" "main" {
  content  = "${tls_private_key.main.private_key_pem}"
  filename = "azure-cvstack.pem"

  provisioner "local-exec" {
    command = "chmod 600 azure-cvstack.pem"
  }
}

output "public-fqdn" {
  value = "${module.core.public-fqdn}"
}
