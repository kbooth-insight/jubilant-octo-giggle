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
echo '${element(data.template_file.module.*.rendered, count.index)}' > /etc/consul.d/server/consul.hcl
sudo systemctl enable consul-server.service
sudo systemctl start consul-server.service
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

data "template_file" "module" {
  count    = "${var.count}"
  template = "${file("${path.module}/consul-server-config.tpl")}"

  vars {
    node_name      = "${local.module_name}vm${count.index}"
    consul_count   = "${var.count}"
    consul_encrypt = "${var.consul_encrypt}"
    consul_address = "${element(azurerm_network_interface.module.*.private_ip_address,count.index)}"
    consul_nodes   = "${join(",", formatlist("\"%s\"", azurerm_network_interface.module.*.private_ip_address))}"
    data_dir       = "/opt/consul"
    domain         = "${var.domain}"
    datacenter     = "${var.datacenter}"
  }
}

# local files here can be removed, just to see what the configs will look like
resource "local_file" "module" {
  count    = "${var.count}"
  content  = "${element(data.template_file.module.*.rendered,count.index)}"
  filename = "./.terraform/${local.module_name}-consul-server-config-tf${count.index}.hcl"
}
