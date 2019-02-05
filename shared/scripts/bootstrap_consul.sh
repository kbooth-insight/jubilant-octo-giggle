#!/bin/bash

set -e

# Disable interactive apt prompts
export DEBIAN_FRONTEND=noninteractive

# Dependencies
sudo apt-get install -y software-properties-common
sudo apt-get update
sudo apt-get install -y unzip tree redis-tools jq curl tmux python-pip

# Disable the firewall
sudo ufw disable || echo "ufw not installed"

# Install semver for get_enterprise_url script
sudo pip install semver

cd /ops

CONFIGDIR=/ops/config

CONSULDOWNLOAD=$(python scripts/get_enterprise_url.py -p consul)
CONSULCONFIGDIR=/etc/consul.d
CONSULDIR=/opt/consul

##########
# Consul #
##########

## Download
curl -L $CONSULDOWNLOAD > consul.zip

## Install
sudo unzip consul.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/consul
sudo chown root:root /usr/local/bin/consul

## Manage directories and permissions
sudo mkdir -p $CONSULCONFIGDIR
sudo chmod 755 $CONSULCONFIGDIR
sudo mkdir -p $CONSULDIR
sudo chmod 755 $CONSULDIR
