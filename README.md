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

Run `make build` to build a machine image with Packer in Azure. Or, to build the image manually run `HASHI_PRODUCT=consul packer build packer.json` followed by `HASHI_PRODUCT=vault packer build packer.json` and take note of the ManagedImageId values. Store the resulting ManagedImageIds in consul_image_id and vault_image_id respectively in terraform.tfvars or TF_VAR_consul_image_id and TF_VAR_vault_image_id.

Run `make prepare` to download dependencies and see what Terraform thinks it needs to do.

Run `make deploy` to start spending money.
