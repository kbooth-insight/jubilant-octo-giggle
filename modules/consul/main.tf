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
echo '${element(data.template_file.module.*.rendered, count.index)}' > /etc/consul.d/consul.hcl
sudo systemctl enable consul-server.service
sudo systemctl start consul-server.service
cp /var/lib/waagent/${element(azurerm_key_vault_certificate.module.*.thumbprint, count.index)}.prv /home/${var.username}/server.key
cp /var/lib/waagent/${element(azurerm_key_vault_certificate.module.*.thumbprint, count.index)}.crt /home/${var.username}/server.crt
CONFIG
  }

  os_profile_secrets {
    source_vault_id = "${var.vault_id}"

    vault_certificates {
      certificate_url = "${element(azurerm_key_vault_certificate.module.*.secret_id, count.index)}"
    }
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
  }
}

# local files here can be removed, just to see what the configs will look like
resource "local_file" "module" {
  count    = "${var.count}"
  content  = "${element(data.template_file.module.*.rendered,count.index)}"
  filename = "./.terraform/${local.module_name}-consul-server-config-tf${count.index}.hcl"
}

resource "azurerm_key_vault_certificate" "module" {
  name         = "${local.module_name}vm${count.index}cert"
  key_vault_id = "${var.vault_id}"
  count        = "${var.count}"

  certificate_policy {
    issuer_parameters {
      name = "Self"
    }

    key_properties {
      exportable = true
      key_size   = 2048
      key_type   = "RSA"
      reuse_key  = true
    }

    lifetime_action {
      action {
        action_type = "AutoRenew"
      }

      trigger {
        days_before_expiry = 30
      }
    }

    secret_properties {
      content_type = "application/x-pkcs12"
    }

    x509_certificate_properties {
      # Server Authentication = 1.3.6.1.5.5.7.3.1
      # Client Authentication = 1.3.6.1.5.5.7.3.2
      extended_key_usage = ["1.3.6.1.5.5.7.3.1"]

      key_usage = [
        "cRLSign",
        "dataEncipherment",
        "digitalSignature",
        "keyAgreement",
        "keyCertSign",
        "keyEncipherment",
      ]

      subject_alternative_names {
        dns_names = ["${local.module_name}vm${count.index}.${var.domain}"]
      }

      subject            = "CN=${var.domain}"
      validity_in_months = 12
    }
  }
}
