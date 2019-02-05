# WORK IN PROGRESS

## Consul Enterprise + Vault Enterprise Cluster in Microsoft Azure

### Setup
Set the following environment variables:

```
ARM_SUBSCRIPTION_ID
ARM_TENANT_ID
ARM_CLIENT_ID
ARM_CLIENT_SECRET
```

Install the Azure CLI tools. They are available in most popular package managers. `brew install azure-cli`, `apt install azure-cli`, etc.

Login to Azure CLI (`az login`).

Run `make build` to build a machine image with Packer in Azure. Or, to build the image manually first create a resource group (`az group create --name cvstack --location "East US"`), then run `HASHI_PRODUCT=consul packer build packer.json` followed by `HASHI_PRODUCT=vault packer build packer.json` and take note of the ManagedImageId values. Store the resulting ManagedImageIds in consul_image_id and vault_image_id respectively in terraform.tfvars or TF_VAR_consul_image_id and TF_VAR_vault_image_id as environment variables.

Run `make prepare` to download dependencies and see what Terraform thinks it needs to do.

Run `make deploy` to start spending money.
