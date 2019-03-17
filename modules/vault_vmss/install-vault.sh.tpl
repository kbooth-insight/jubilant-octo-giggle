#!/bin/bash

# Get private ip address of node
readonly NODE_IP="$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')"

# copy consul config
sudo cat << EOF > /etc/consul.d/client/consul.hcl
${consul_config_contents}
EOF

# copy vault config
sudo cat << EOF > /etc/vault.d/vault.hcl
${vault_config_contents}
EOF

sudo /opt/hashi/prepare_vm_disk.sh

sudo systemctl enable consul-client.service
sudo systemctl start consul-client.service

sudo systemctl enable vault.service
sudo systemctl start vault.service
