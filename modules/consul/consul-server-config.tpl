datacenter = "dc1"
server = true
bootstrap_expect = ${consul_count}
node_name = "${node_name}"
data_dir = "/opt/consul"
bind_addr = "${consul_address}"
client_addr = "127.0.0.1"
encrypt = "${consul_encrypt}"
retry_join = [${consul_nodes}]
log_level = "DEBUG"
ui = true
enable_syslog = true
acl_enforce_version_8 = true
addresses {
  http = "${consul_address}"
}
ports {
  https = 8501
}

# key_file = "{{ssl_key_dir}}/server.key"
# cert_file = "{{ssl_cert_dir}}/server.crt"

#config generated from Terraform
