resource "azurerm_network_interface" "module" {
  resource_group_name       = "${var.resource_group_name}"
  location                  = "${var.location}"
  name                      = "${local.module_name}-nic${count.index}"
  count                     = "${var.count}"
  network_security_group_id = "${var.network_security_group_id}"

  ip_configuration {
    name                          = "ipConfig"
    subnet_id                     = "${var.subnet_id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${var.tags}"
}

resource "azurerm_virtual_machine" "module" {
  resource_group_name              = "${var.resource_group_name}"
  location                         = "${var.location}"
  name                             = "${local.module_name}vm${count.index}"
  name                             = "${local.module_name}vm${count.index}"
  network_interface_ids            = ["${element(azurerm_network_interface.module.*.id, count.index)}"]
  count                            = "${var.count}"
  vm_size                          = "${var.size}"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    name              = "${local.module_name}-vm${count.index}-os"
    managed_disk_type = "${var.disk_os_sku}"
  }

  storage_data_disk {
    create_option     = "Empty"
    lun               = 0
    name              = "${local.module_name}-vm${count.index}-data0"
    managed_disk_type = "${var.disk_data_sku}"
    disk_size_gb      = "${var.disk_data_size_gb}"
  }

  storage_image_reference {
    id = "${var.os_image_id}"
  }

  os_profile {
    computer_name  = "${local.module_name}vm${count.index}"
    admin_username = "${var.username}"

    custom_data = <<CONFIG
#!/bin/bash
echo '${element(data.template_file.consul.*.rendered, count.index)}' > /etc/consul.d/client/consul.hcl
sudo systemctl enable consul-client.service
sudo systemctl start consul-client.service
echo '${element(data.template_file.vault.*.rendered, count.index)}' > /etc/vault.d/vault.hcl
sudo systemctl enable vault.service
sudo systemctl start vault.service
CONFIG
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

data "template_file" "consul" {
  count    = "${var.count}"
  template = "${file("${path.module}/consul-client-config.tpl")}"

  vars {
    node_name      = "${local.module_name}vm${count.index}"
    vault_address  = "${element(azurerm_network_interface.module.*.private_ip_address,count.index)}"
    consul_encrypt = "${var.consul_encrypt}"
    consul_nodes   = "${var.consul_nodes}"
    data_dir       = "/opt/consul"
    domain         = "${var.domain}"
    datacenter     = "${var.datacenter}"
  }
}

data "template_file" "vault" {
  count    = "${var.count}"
  template = "${file("${path.module}/vault-config.tpl")}"

  vars {
    vault_address = "${element(azurerm_network_interface.module.*.private_ip_address,count.index)}"

    auto_tenant_id     = "${data.azurerm_client_config.current.tenant_id}"
    auto_client_id     = "${data.azurerm_client_config.current.client_id}"
    auto_client_secret = "${var.vault_unseal_client_id}"
    auto_vault_name    = "${var.vault_name}"
    auto_key_name      = "${azurerm_key_vault_key.module.name}"
  }
}

# local files here can be removed, just to see what the configs will look like
resource "local_file" "consul" {
  count    = "${var.count}"
  content  = "${element(data.template_file.consul.*.rendered,count.index)}"
  filename = "./.terraform/${local.module_name}-consul-client-config-tf${count.index}.hcl"
}

resource "local_file" "vault" {
  count    = "${var.count}"
  content  = "${element(data.template_file.vault.*.rendered,count.index)}"
  filename = "./.terraform/${local.module_name}-vault-config-tf${count.index}.hcl"
}

# Auto unseal key
resource "azurerm_key_vault_key" "module" {
  key_vault_id = "${var.vault_id}"
  name         = "${local.module_name}-vault-unseal"
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]
}
