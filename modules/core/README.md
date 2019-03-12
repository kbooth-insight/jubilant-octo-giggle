## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| disk\_os\_sku | Managed disk SKU for the OS disk | string | `"Premium_LRS"` | no |
| key\_vault\_object\_ids | The additonal object ids to add to the keyvault (Optional) | list | `<list>` | no |
| location | The Azure location to create all resources in. | string | n/a | yes |
| name | A unique name that identifies the module. | string | `"core"` | no |
| os | The Marketplace image information in the following format: Offer:Publisher:Sku:Version | string | `"Canonical:UbuntuServer:16.04.0-LTS:latest"` | no |
| public\_key\_openssh | The public SSH key. | string | n/a | yes |
| resource\_group\_name | The resource group to place module resources. | string | n/a | yes |
| size | VM SKU to provision | string | `"Standard_DS1_v2"` | no |
| subnet\_address\_prefixes | List of Subnet Address Prefixes. Each prefix will result in a new Subnet | list | n/a | yes |
| tags | Tags to be applied to resources. | map | n/a | yes |
| username | The admin username for the Virtual Machines. | string | `"cvstackadmin"` | no |
| vnet\_address\_spacing | List of Address Spaces for the Virtual Network | list | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| keyvault\_id |  |
| keyvault\_name |  |
| network-security-group-id |  |
| public-fqdn |  |
| subnet-ids | Id's of the Subnets |
| virtualnetwork-ids | Id of the Vnet |
