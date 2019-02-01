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

Run `make build` to build a machine image with Packer in Azure. Or, to build the image manually run `packer build packer.json`

Run `make prepare` to download dependencies and see what Terraform thinks it needs to do.

Run `make deploy` to start spending money.
