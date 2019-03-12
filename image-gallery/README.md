## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| images\_ids | List of Azure Managed Images to store in the gallery | list | n/a | yes |
| location | The Azure location to which to deploy. | string | `"eastus"` | no |
| offer |  | string | `"consul-vault"` | no |
| prefix | Unique affix to avoid resource duplication. | string | `"hashistack"` | no |
| publisher |  | string | `"hashiPS"` | no |
| resource\_group\_name | The resource group to put the image gallery in | string | `"hashistack-images-rg"` | no |
| secondary\_location | The Azure location to which to replcate the image | string | `"centralus"` | no |
| sku |  | string | `"enterprise"` | no |

## Outputs

| Name | Description |
|------|-------------|
| consul-vault-images |  |
