variable "resource_group_name" {
  description = "The resource group to place module resources."
}

variable "cluster_name" {
  description = "A unique name that identifies the cluster."
}

variable "location" {
  description = "The Azure location to create all resources in."
}

variable "subnet_id" {
  description = "The Azure Id of the Azure Subnet to use when creating the Virtual Machines."
}

variable "network_security_group_id" {
  description = "The Azure Id of the Azure NSG to use when creating the Network Interface."
}

variable "username" {
  description = "The admin username for the Virtual Machines."
  default     = "cvstackadmin"
}

variable "public_key_openssh" {
  description = "The public SSH key."
}

variable "consul_encrypt" {
  description = "Encryption key to place in the consul configuration."
}

variable "vault_id" {
  description = "The id of the Azure Key Vault"
}

variable "vault_name" {
  description = "The name of the Azure Key Vault"
}

variable "vault_unseal_client_id" {
  # Currently cant source this from the data.azurerm_client_config
  description = "Client secret for autounseal."
}

variable "domain" {
  description = "Domain to create self-signed certs for."
}

variable "consul_count" {
  description = "The number of nodes to create."
  default     = 5
}

variable "vault_count" {
  description = "The number of nodes to create."
  default     = 3
}

variable "consul_image_id" {
  type        = "string"
  description = "The custom Azure image to use."
}

variable "vault_image_id" {
  type        = "string"
  description = "The custom Azure image to use."
}

variable "tags" {
  type        = "map"
  description = "Tags to be applied to resources."
}
