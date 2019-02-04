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

VAULTDOWNLOAD=$(python scripts/get_enterprise_url.py -p vault)
VAULTCONFIGDIR=/etc/vault.d
VAULTDIR=/opt/vault

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

#########
# Vault #
#########

## Download
curl -L $VAULTDOWNLOAD > vault.zip

## Install
sudo unzip vault.zip -d /usr/local/bin
sudo chmod 0755 /usr/local/bin/vault
sudo chown root:root /usr/local/bin/vault

## Manage directories and permissions
sudo mkdir -p $VAULTCONFIGDIR
sudo chmod 755 $VAULTCONFIGDIR
sudo mkdir -p $VAULTDIR
sudo chmod 755 $VAULTDIR
