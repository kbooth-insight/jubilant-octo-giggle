# This configuration was generated by Terraform

## Node
datacenter = "${datacenter}"
node_name  = "${node_name}"
domain     = "${domain}"

## Addresses
bind_addr          = "${vault_address}"
advertise_addr     = "${vault_address}"
advertise_addr_wan = "${vault_address}"
client_addr        = "127.0.0.1"

addresses = {
  dns   = "127.0.0.1"
  http  = "127.0.0.1"
  https = "0.0.0.0"
  grpc  = "127.0.0.1"
}

ports = {
  dns      = 8600
  # http     = -1
  https    = 8501
  serf_lan = 8301
  serf_wan = 8302
  server   = 8300
  grpc     = -1
}

## LAN Join
retry_interval = "30s"
retry_max      = 0
retry_join = [${consul_nodes}]

## Server Settings
server           = false
bootstrap        = false
# autopilot        = {}

## Agent
data_dir                   = "${data_dir}"
# log_level                  = "INFO"
log_level                  = "DEBUG"
enable_syslog              = true
syslog_facility            = "local0"

## Encryption and TLS
encrypt                = "${consul_encrypt}"


