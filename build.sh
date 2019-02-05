#! /usr/bin/env bash

az group create --name cvstack --location "East US"
echo "Created resource group"
echo "Building Consul image with Packer. This will take several minutes."
export TF_VAR_consul_image_id=$(HASHI_PRODUCT=consul packer build -force packer.json | grep "ManagedImageId" | sed 's/.* //g')
echo "Building Vault image with Packer. This will take several minutes."
export TF_VAR_vault_image_id=$(HASHI_PRODUCT=vault packer build -force packer.json | grep "ManagedImageId" | sed 's/.* //g')

echo "consul_image_id=${TF_VAR_consul_image_id}"
echo "vault_image_id=${TF_VAR_vault_image_id}"
