resource "azurerm_resource_group" "module" {
  name     = "test-hahistack-rg"
  location = "centralus"
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
}

resource "local_file" "ssh-public" {
  content  = "${tls_private_key.ssh.public_key_openssh}"
  filename = "secrets/id_rsa.pub"
}

resource "local_file" "ssh-private" {
  content  = "${tls_private_key.ssh.private_key_pem}"
  filename = "secrets/id_rsa.pem"
}

resource "azurerm_virtual_network" "module" {
  name                = "testvnet"
  address_space       = ["10.0.0.0/16"]
  location            = "${azurerm_resource_group.module.location}"
  resource_group_name = "${azurerm_resource_group.module.name}"
}

resource "azurerm_subnet" "module" {
  name                 = "testsubnet${count.index}"
  resource_group_name  = "${azurerm_resource_group.module.name}"
  virtual_network_name = "${azurerm_virtual_network.module.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "random_pet" "module" {
  keepers = {
    ami_id = "${azurerm_resource_group.module.name}"
  }

  length = 2
  prefix = "hashi-teststack"
}

resource "azurerm_public_ip" "module" {
  name = "testpip"

  location                     = "${azurerm_resource_group.module.location}"
  resource_group_name          = "${azurerm_resource_group.module.name}"
  domain_name_label            = "${random_pet.module.id}"
  public_ip_address_allocation = "Dynamic"
  idle_timeout_in_minutes      = 30
}

resource "azurerm_network_interface" "consul" {
  name                = "testnic"
  location            = "${azurerm_resource_group.module.location}"
  resource_group_name = "${azurerm_resource_group.module.name}"

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = "${azurerm_subnet.module.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.module.id}"
  }
}

resource "azurerm_virtual_machine" "consul" {
  name                             = "testvm${count.index}"
  location                         = "${azurerm_resource_group.module.location}"
  resource_group_name              = "${azurerm_resource_group.module.name}"
  network_interface_ids            = ["${azurerm_network_interface.consul.id}"]
  vm_size                          = "Standard_A0"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "${element(split(":",var.os), 0)}"
    offer     = "${element(split(":",var.os), 1)}"
    sku       = "${element(split(":",var.os), 2)}"
    version   = "${element(split(":",var.os), 3)}"
  }

  storage_os_disk {
    caching           = "ReadWrite"
    create_option     = "FromImage"
    name              = "testvm-os"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "testvm"
    admin_username = "testvmuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/testvmuser/.ssh/authorized_keys"
      key_data = "${tls_private_key.ssh.public_key_openssh}"
    }
  }
}

output "test-public-ip" {
  value = "${azurerm_public_ip.module.ip_address}"
}

output "test-public-domain" {
  value = "${azurerm_public_ip.module.fqdn}"
}
