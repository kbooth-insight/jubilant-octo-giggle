#!/bin/bash

# Get private ip address of node
readonly NODE_IP="$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')"

# copy consul config
sudo cat << EOF > /etc/consul.d/server/consul.hcl
${consul_config_contents}
EOF

sudo systemctl enable consul-server.service
sudo systemctl start consul-server.service
