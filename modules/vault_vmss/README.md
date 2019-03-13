## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| consul\_encrypt | Encryption key to place in the consul configuration. | string | n/a | yes |
| consul\_vmss\_name | The name of the VMSS that is consul. Used to autojoin. | string | n/a | yes |
| count | The number of nodes to create. | string | `"3"` | no |
| datacenter | Datacenter to register to. | string | `"dc1"` | no |
| disk\_data\_size\_gb | The size of the data disk | string | `"32"` | no |
| disk\_data\_sku | Managed disk SKU for the OS disk | string | `"Premium_LRS"` | no |
| disk\_os\_sku | Managed disk SKU for the OS disk | string | `"Premium_LRS"` | no |
| domain | Domain. | string | n/a | yes |
| location | The Azure location to create all resources in. | string | n/a | yes |
| name | A unique name that identifies the module. | string | `"vault"` | no |
| network\_security\_group\_id | The Azure Id of the Azure NSG to use when creating the Network Interface. | string | n/a | yes |
| os\_image\_id | The custom Azure image to use. | string | n/a | yes |
| public\_key\_openssh | The public SSH key. | string | n/a | yes |
| resource\_group\_name | The resource group to place module resources. | string | n/a | yes |
| size | VM SKU to provision | string | `"Standard_DS1_v2"` | no |
| spn\_client\_id | Service Principal Id used by the nodes to access auto-join and AKV. | string | n/a | yes |
| spn\_client\_secret | Service Principal Secret used by the nodes to access auto-join and AKV. | string | n/a | yes |
| subnet\_id | The Azure Id of the Azure Subnet to use when creating the Virtual Machines. | string | n/a | yes |
| tags | Tags to be applied to resources. | map | n/a | yes |
| tier | VM Tier to provision | string | `"standard"` | no |
| username | The admin username for the Virtual Machines. | string | `"cvstackadmin"` | no |
| vault\_id | The id of the Azure Key Vault | string | n/a | yes |
| vault\_name | The name of the Azure Key Vault | string | n/a | yes |
| vault\_unseal\_client\_id | Client secret for autounseal. | string | n/a | yes |
