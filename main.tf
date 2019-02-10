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

resource "azurerm_resource_group" "cvstackgroup" {
  name     = "cvstack"
  location = "${var.location}"

  tags = "${local.common_tags}"
}

resource "azurerm_virtual_network" "cvstacknetwork" {
  name                = "cvstack-net"
  address_space       = ["10.0.0.0/16"]
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cvstackgroup.name}"

  tags = "${local.common_tags}"
}

resource "azurerm_subnet" "cvstacksubnet" {
  name                 = "cvstack-default-subnet"
  resource_group_name  = "${azurerm_resource_group.cvstackgroup.name}"
  virtual_network_name = "${azurerm_virtual_network.cvstacknetwork.name}"
  address_prefix       = "10.0.1.0/24"
}

resource "azurerm_public_ip" "cvstackpublicip" {
  name                         = "cvstackpubip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.cvstackgroup.name}"
  public_ip_address_allocation = "dynamic"

  tags = "${local.common_tags}"
}

resource "azurerm_network_security_group" "cvstackpubnsg" {
  name                = "myNetworkSecurityGroup"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cvstackgroup.name}"

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

  tags = "${local.common_tags}"
}

resource "azurerm_network_interface" "cvstackpublicnic" {
  name                      = "bastionNIC"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.cvstackgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.cvstackpubnsg.id}"

  ip_configuration {
    name                          = "bastionNicConfiguration"
    subnet_id                     = "${azurerm_subnet.cvstacksubnet.id}"
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = "${azurerm_public_ip.cvstackpublicip.id}"
  }

  tags = "${local.common_tags}"
}

resource "azurerm_network_interface" "consul_nics" {
  name                      = "consul-nic${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.cvstackgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.cvstackpubnsg.id}"
  count                     = "${var.consul_count}"

  ip_configuration {
    name                          = "counsul-nic${count.index}"
    subnet_id                     = "${azurerm_subnet.cvstacksubnet.id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${local.common_tags}"
}

resource "azurerm_network_interface" "vault_nics" {
  name                      = "vault-nic${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.cvstackgroup.name}"
  network_security_group_id = "${azurerm_network_security_group.cvstackpubnsg.id}"
  count                     = "${var.consul_count}"

  ip_configuration {
    name                          = "vault-nic${count.index}"
    subnet_id                     = "${azurerm_subnet.cvstacksubnet.id}"
    private_ip_address_allocation = "dynamic"
  }

  tags = "${local.common_tags}"
}

resource "random_id" "randomId" {
  keepers = {
    resource_group = "${azurerm_resource_group.cvstackgroup.name}"
  }

  byte_length = 8
}

resource "azurerm_storage_account" "cvstacksa" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = "${azurerm_resource_group.cvstackgroup.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = "${local.common_tags}"
}

resource "azurerm_virtual_machine" "cvstackbastion" {
  name                = "bastionbox"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cvstackgroup.name}"

  // Bastion node will have a public IP
  network_interface_ids = ["${azurerm_network_interface.cvstackpublicnic.id}"]
  vm_size               = "Standard_DS1_v2"

  storage_os_disk {
    name              = "cvstackbastiondisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "cvstack-bastion"
    admin_username = "cvstackadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/cvstackadmin/.ssh/authorized_keys"
      key_data = "${tls_private_key.main.public_key_openssh}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.cvstacksa.primary_blob_endpoint}"
  }
  tags = "${local.common_tags}"
}

resource "azurerm_virtual_machine" "cvstackconsulnode" {
  name                = "consulbox${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cvstackgroup.name}"

  // Vault and Consul nodes only have NICs on the private subnet
  network_interface_ids = ["${element(azurerm_network_interface.consul_nics.*.id, count.index)}"]
  vm_size               = "${var.consul_machine_size}"
  count                 = "${var.consul_count}"

  storage_os_disk {
    name              = "cvstackconsuldisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id = "${var.consul_image_id}"
  }

  os_profile {
    computer_name  = "cvstack-consul${count.index}"
    admin_username = "cvstackadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/cvstackadmin/.ssh/authorized_keys"
      key_data = "${tls_private_key.main.public_key_openssh}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.cvstacksa.primary_blob_endpoint}"
  }
  tags = "${local.common_tags}"
}

resource "azurerm_virtual_machine" "cvstackvaultnode" {
  name                = "vaultbox${count.index}"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.cvstackgroup.name}"

  // Vault and Consul nodes only have NICs on the private subnet
  network_interface_ids = ["${element(azurerm_network_interface.vault_nics.*.id, count.index)}"]
  vm_size               = "${var.vault_machine_size}"
  count                 = "${var.consul_count}"

  storage_os_disk {
    name              = "cvstackvaultdisk${count.index}"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Premium_LRS"
  }

  storage_image_reference {
    id = "${var.vault_image_id}"
  }

  os_profile {
    computer_name  = "cvstack-consul${count.index}"
    admin_username = "cvstackadmin"
  }

  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/cvstackadmin/.ssh/authorized_keys"
      key_data = "${tls_private_key.main.public_key_openssh}"
    }
  }

  boot_diagnostics {
    enabled     = "true"
    storage_uri = "${azurerm_storage_account.cvstacksa.primary_blob_endpoint}"
  }

  tags = "${local.common_tags}"
}

output "jump-public-ip" {
  value = "${azurerm_public_ip.cvstackpublicip.ip_address}"
}

output "private_key" {
  value = "${tls_private_key.main.private_key_openssh}"
}
