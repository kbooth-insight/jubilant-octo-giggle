# WORK IN PROGRESS

## Consul Enterprise + Vault Enterprise Cluster in Microsoft Azure

### Install Dependencies

Install the Azure CLI tools. They are available in most popular package managers. `brew install azure-cli`, `apt install azure-cli`, etc.

Install ansible locally (`brew install ansible`).

sudo pip install semver

### Packer Build

The following environment variables are required:

```sh
export ARM_SUBSCRIPTION_ID=""
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
```

(Optionally) Set the following environment variables to override default behavior:
```sh
# The resource group to create (if it doesn't exist) and place the managed image
export AZURE_RESOURCE_GROUP="hashistack-images-rg"
# The location in Azure to create the resource group and managed image
export AZURE_LOCATION="eastus"
# The name to give the managed image
export IMAGE_NAME="hashiconsul-vault-image"
# The version of the image (is used to create the image name)
export IMAGE_VERSION="v0.1"
```

Login to Azure CLI (`az login`).

Run `make build` to build a managed image with Packer in Azure.

You can also run this step manually and take note of the ManagedImageId value:

```sh
packer build \
    -var "azure_subscription_id=${ARM_SUBSCRIPTION_ID}" \
    -var "azure_client_id=${ARM_CLIENT_ID}" \
    -var "azure_client_secret=${ARM_CLIENT_SECRET}" \
    -var "azure_resource_group=${AZURE_RESOURCE_GROUP}" \
    -var "azure_location=${AZURE_LOCATION}" \
    -var "image_name=${IMAGE_NAME}" \
    -var "image_version=${IMAGE_VERSION}" \
    -force packer.json
```

Or, to build the image manually first create a resource group (`az group create --name cvstack --location "East US"`), then run `HASHI_PRODUCT=consul packer build packer.json` followed by `HASHI_PRODUCT=vault packer build packer.json` and take note of the ManagedImageId values. 

Set the resulting ManagedImageId in os_image_id in terraform.tfvars:

```hcl
os_image="/subscriptions/xxx/resourceGroups/xxx/providers/Microsoft.Compute/images/xxx"
```

## Terraform Workflow

Run `make prepare` to download dependencies and see what Terraform thinks it needs to do.

Run `make deploy` to start spending :money_with_wings:.

## Connect

SSH into one of the Vault clusters, you can use any of the IP's given in `terraform output`:

```sh
$ terraform output
consul_cluster1-ips = [
    10.0.1.6,
    10.0.1.7,
    10.0.1.5
]
public-fqdn = strangely-singular-marten.eastus.cloudapp.azure.com
vault-cluster1-ips = [
    10.0.1.9,
    10.0.1.8
]
```

Once connected, run `vault operator init -address="http://10.0.1.8:8200"` and capture the keys/token.

Check the status:

```sh
$ vault status -address="http://10.0.1.8:8200"
Key                      Value
---                      -----
Recovery Seal Type       shamir
Initialized              true
Sealed                   false
Total Recovery Shares    5
Threshold                3
Version                  1.1.0-beta1+ent
Cluster Name             vault-cluster-f1b8b163
Cluster ID               5e308822-168c-9468-762e-a9d212359bd5
HA Enabled               true
HA Cluster               https://10.0.1.8:8201
HA Mode                  active
Last WAL                 16
```

# Terraform root Module

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul\_count | The number of Consul nodes to deploy. | string | `"5"` | no |
| consul\_encrypt | The encrypt key deployed to the consul nodes. | string | n/a | yes |
| consul\_machine\_size | The machine size to use for Consul. | string | `"Standard_DS1_v2"` | no |
| domain | The domain | string | `"consul"` | no |
| key\_vault\_object\_ids | The additonal object ids to add to the keyvault (Optional) | list | `[]` | no |
| location | The Azure location to which to deploy. | string | `"eastus"` | no |
| os\_image\_id | The Image ID to use for the base VM for Consul and Vault. | string | n/a | yes |
| prefix | Unique affix to avoid resource duplication. | string | `"hashistack"` | no |
| subnet\_address\_prefixes | List of Subnet Address Prefixes. Each prefix will result in a new Subnet | list | `[ "10.0.1.0/24", "10.0.2.0/24" ]` | no |
| vault\_count | The number of Vault nodes to deploy. | string | `"3"` | no |
| vault\_machine\_size | The machine size to use for Vault. | string | `"Standard_DS1_v2"` | no |
| vault\_unseal\_client\_id | Client secret for autounseal. | string | n/a | yes |
| vnet\_address\_spacing | List of Address Spaces for the Virtual Network | list | `[ "10.0.0.0/16" ]` | no |

## Outputs

| Name | Description |
|------|-------------|
| public-fqdn |  |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->