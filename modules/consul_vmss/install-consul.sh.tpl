#!/bin/bash

# Install Azure CLI
sudo apt-get install apt-transport-https lsb-release software-properties-common dirmngr -y
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" |     sudo tee /etc/apt/sources.list.d/azure-cli.list
sudo apt-key --keyring /etc/apt/trusted.gpg.d/Microsoft.gpg adv      --keyserver packages.microsoft.com      --recv-keys BC528686B50D79E339D3721CEB3E94ADBE1229CF
sudo apt-get update
sudo apt-get install azure-cli

# az login --identity > /tmp/azlogin.json

# Get private ip address of node
readonly NODE_IP="$(/sbin/ifconfig eth0 | grep 'inet addr' | cut -d: -f2 | awk '{print $1}')"

# copy consul config
sudo cat << EOF > /etc/consul.d/server/consul.hcl
${consul_config_contents}
EOF

sudo systemctl enable consul-server.service
sudo systemctl start consul-server.service
