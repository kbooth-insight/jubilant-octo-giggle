resource "azurerm_virtual_network" "module" {
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  name                = "${local.module_name}-vnet"
  address_space       = "${var.vnet_address_spacing}"

  tags = "${var.tags}"
}

resource "azurerm_subnet" "module" {
  resource_group_name  = "${var.resource_group_name}"
  name                 = "${local.module_name}-subnet${count.index}"
  count                = "${length(var.subnet_address_prefixes)}"
  virtual_network_name = "${azurerm_virtual_network.module.name}"
  address_prefix       = "${var.subnet_address_prefixes[count.index]}"
}

resource "azurerm_network_security_group" "module" {
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  name                = "${local.module_name}-nsg"

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = "${var.tags}"
}

resource "random_pet" "module" {
  keepers = {
    ami_id = "${local.module_name}"
  }

  length = 3
}

resource "azurerm_public_ip" "module" {
  resource_group_name = "${var.resource_group_name}"
  location            = "${var.location}"
  name                = "${local.module_name}-publicip"
  domain_name_label   = "${random_pet.module.id}"
  allocation_method   = "Dynamic"

  tags = "${var.tags}"
}

resource "azurerm_network_interface" "module" {
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.location}"
  name                      = "bastionNIC"
  network_security_group_id = "${azurerm_network_security_group.module.id}"

  ip_configuration {
    name                          = "ipConfig"
    subnet_id                     = "${element(azurerm_subnet.module.*.id,0)}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.module.id}"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "module" {
  resource_group_name   = "${var.resource_group_name}"
  location              = "${var.location}"
  name                  = "bastionbox"
  network_interface_ids = ["${azurerm_network_interface.module.id}"]
  vm_size               = "${var.size}"

  storage_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    name              = "${local.module_name}-vm${count.index}-os"
    managed_disk_type = "${var.disk_os_sku}"
  }

  storage_image_reference {
    publisher = "${element(split(":",var.os), 0)}"
    offer     = "${element(split(":",var.os), 1)}"
    sku       = "${element(split(":",var.os), 2)}"
    version   = "${element(split(":",var.os), 3)}"
  }

  os_profile {
    computer_name  = "cvstack-bastion"
    admin_username = "${var.username}"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/${var.username}/.ssh/authorized_keys"
      key_data = "${var.public_key_openssh}"
    }
  }

  tags = "${var.tags}"
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = "${var.resource_group_name}"
  }

  byte_length = 8
}

resource "azurerm_key_vault" "main" {
  resource_group_name             = "${var.resource_group_name}"
  location                        = "${var.location}"
  name                            = "azkey${random_id.randomId.hex}"
  tenant_id                       = "${data.azurerm_client_config.current.tenant_id}"
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  sku {
    name = "standard"
  }

  tags = "${var.tags}"
}

# resource "azurerm_key_vault_access_policy" "spn_policy" {
#   key_vault_id = "${azurerm_key_vault.main.id}"
#   tenant_id    = "${data.azurerm_client_config.current.tenant_id}"
#   object_id    = "${data.azurerm_client_config.current.service_principal_object_id}"

#   certificate_permissions = [
#     "create",
#     "delete",
#     "deleteissuers",
#     "get",
#     "getissuers",
#     "import",
#     "list",
#     "listissuers",
#     "managecontacts",
#     "manageissuers",
#     "setissuers",
#     "update",
#   ]

#   key_permissions = [
#     "backup",
#     "create",
#     "decrypt",
#     "delete",
#     "encrypt",
#     "get",
#     "import",
#     "list",
#     "purge",
#     "recover",
#     "restore",
#     "sign",
#     "unwrapKey",
#     "update",
#     "verify",
#     "wrapKey",
#   ]

#   secret_permissions = [
#     "backup",
#     "delete",
#     "get",
#     "list",
#     "purge",
#     "recover",
#     "restore",
#     "set",
#   ]
# }

resource "azurerm_key_vault_access_policy" "additional_policies" {
  key_vault_id = "${azurerm_key_vault.main.id}"
  tenant_id    = "${data.azurerm_client_config.current.tenant_id}"
  count        = "${length(var.key_vault_object_ids)}"
  object_id    = "${element(var.key_vault_object_ids, count.index)}"

  certificate_permissions = [
    "create",
    "delete",
    "deleteissuers",
    "get",
    "getissuers",
    "import",
    "list",
    "listissuers",
    "managecontacts",
    "manageissuers",
    "setissuers",
    "update",
  ]

  key_permissions = [
    "backup",
    "create",
    "decrypt",
    "delete",
    "encrypt",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "sign",
    "unwrapKey",
    "update",
    "verify",
    "wrapKey",
  ]

  secret_permissions = [
    "backup",
    "delete",
    "get",
    "list",
    "purge",
    "recover",
    "restore",
    "set",
  ]
}
