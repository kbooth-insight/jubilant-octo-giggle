ui = true
api_addr = "http://$${NODE_IP}:8200"
cluster_addr = "http://$${NODE_IP}:8201"
storage "consul" {
  address = "127.0.0.1:8500"
  path    = "vault/"
}

listener "tcp" {
  address          = "0.0.0.0:8200"
  cluster_address  = "$${NODE_IP}:8201"
  tls_disable = true
}

seal "azurekeyvault" {
  tenant_id      = "${auto_tenant_id}"
  client_id      = "${auto_client_id}"
  client_secret  = "${auto_client_secret}"
  vault_name     = "${auto_vault_name}"
  key_name       = "${auto_key_name}"
}