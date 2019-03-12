data "template_file" "consul-config" {
  template = "${file("${path.module}/consul.hcl.tpl")}"

  vars {
    data_dir       = "/opt/consul"
    consul_encrypt = "${var.consul_encrypt}"
    consul_count   = "${var.count}"

    vm_scale_set      = "${local.vmss_name}"
    resource_group    = "${var.resource_group_name}"
    tenant_id         = "${data.azurerm_client_config.primary.tenant_id}"
    subscription_id   = "${data.azurerm_subscription.primary.subscription_id}"
    client_id         = "${var.spn_client_id}"
    secret_access_key = "${var.spn_client_secret}"
  }
}

data "template_file" "consul-install" {
  template = "${file("${path.module}/install-consul.sh.tpl")}"

  vars {
    consul_config_contents = "${data.template_file.consul-config.rendered}"
  }
}

# local files here can be removed, just to see what the configs will look like
resource "local_file" "consul-install" {
  content  = "${data.template_file.consul-install.rendered}"
  filename = "./.terraform/${local.module_name}-install-consul.sh"
}

resource "local_file" "consul-config" {
  content  = "${data.template_file.consul-config.rendered}"
  filename = "./.terraform/${local.module_name}-consul.hcl"
}
