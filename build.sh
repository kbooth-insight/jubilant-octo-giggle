#! /usr/bin/env bash
set -e

# Must set these and login to the azure cli `az login`
# ARM_SUBSCRIPTION_ID
# ARM_CLIENT_ID
# ARM_CLIENT_SECRET
# Optional with defaults
AZURE_RESOURCE_GROUP=${AZURE_RESOURCE_GROUP:-"hashistack-images-rg"}
AZURE_LOCATION=${AZURE_LOCATION:-"eastus"}
IMAGE_NAME=${IMAGE_NAME:-"hashiconsul-vault-image"}
IMAGE_VERSION=${IMAGE_VERSION:-"v0.1"}

if [ $(az group exists --name ${AZURE_RESOURCE_GROUP}) != "true" ]
then
    echo "Create resource group '${AZURE_RESOURCE_GROUP}'." 
    az group create --name ${AZURE_RESOURCE_GROUP} --location "${AZURE_LOCATION}"
else
    echo "Resource group '${AZURE_RESOURCE_GROUP}' already exists."
fi

echo "Building HashiStack image with Packer. This will take several minutes."
packer build \
    -var "azure_subscription_id=${ARM_SUBSCRIPTION_ID}" \
    -var "azure_client_id=${ARM_CLIENT_ID}" \
    -var "azure_client_secret=${ARM_CLIENT_SECRET}" \
    -var "azure_resource_group=${AZURE_RESOURCE_GROUP}" \
    -var "azure_location=${AZURE_LOCATION}" \
    -var "image_name=${IMAGE_NAME}" \
    -var "image_version=${IMAGE_VERSION}" \
    -force packer.json | \
    grep "ManagedImageId" | \
    sed 's/.* //g'
