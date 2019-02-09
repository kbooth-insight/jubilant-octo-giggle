#! /usr/bin/env bash
set -e

AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP:-"cvstack"}
AZURE_LOATION=${AZURE_LOCATION:-"East US"}

if [ ! $(az group exists --name ${AZURE_RESOURCE_GROUP}) ]
then
    az group create --name ${AZURE_RESOURCE_GROUP} --location "${AZURE_LOCATION}"
fi

echo "Created resource group"
echo "Building Consul image with Packer. This will take several minutes."
export TF_VAR_consul_image_id=$(AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP} HASHI_PRODUCT=consul packer build -var 'managed_image_name=consul-image' -force packer.json | grep "ManagedImageId" | sed 's/.* //g')
echo "Building Vault image with Packer. This will take several minutes."
export TF_VAR_vault_image_id=$(AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP} HASHI_PRODUCT=vault packer build -var 'managed_image_name=vault-image' -force packer.json | grep "ManagedImageId" | sed 's/.* //g')

echo "consul_image_id=${TF_VAR_consul_image_id}"
echo "vault_image_id=${TF_VAR_vault_image_id}"
