data "template_file" "consul-config" {
  template = "${file("${path.module}/consul.hcl.tpl")}"

  vars {
    data_dir       = "/opt/consul"
    consul_encrypt = "${var.consul_encrypt}"
    consul_node    = "ip"

    vm_scale_set      = "${var.consul_vmss_name}"
    resource_group    = "${var.resource_group_name}"
    tenant_id         = "${data.azurerm_client_config.primary.tenant_id}"
    subscription_id   = "${data.azurerm_subscription.primary.subscription_id}"
    client_id         = "${var.spn_client_id}"
    secret_access_key = "${var.spn_client_secret}"
  }
}

data "template_file" "vault-config" {
  template = "${file("${path.module}/vault.hcl.tpl")}"

  vars {
    auto_tenant_id       = "${data.azurerm_client_config.primary.tenant_id}"
    auto_subscription_id = "${data.azurerm_subscription.primary.subscription_id}"
    auto_client_id       = "${var.spn_client_id}"
    auto_client_secret   = "${var.spn_client_secret}"
    auto_vault_name      = "${var.vault_name}"
    auto_key_name        = "${azurerm_key_vault_key.module.name}"
  }
}

data "template_file" "vault-install" {
  template = "${file("${path.module}/install-vault.sh.tpl")}"

  vars {
    consul_config_contents = "${data.template_file.consul-config.rendered}"
    vault_config_contents  = "${data.template_file.vault-config.rendered}"
  }
}

# local files here can be removed, just to see what the configs will look like
resource "local_file" "vault-install" {
  content  = "${data.template_file.vault-install.rendered}"
  filename = "./.terraform/${local.module_name}-install-vault.sh"
}

resource "local_file" "consul-config" {
  content  = "${data.template_file.consul-config.rendered}"
  filename = "./.terraform/${local.module_name}-consul.hcl"
}

resource "local_file" "vault-config" {
  content  = "${data.template_file.vault-config.rendered}"
  filename = "./.terraform/${local.module_name}-vault.hcl"
}
