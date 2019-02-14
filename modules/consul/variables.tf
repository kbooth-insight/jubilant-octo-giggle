variable "resource_group_name" {
  description = "The resource group to place module resources."
}

variable "name" {
  description = "A unique name that identifies the module."
  default     = "consul"
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

variable "domain" {
  description = "Domain to create self-signed certs for."
}

variable "count" {
  description = "The number of nodes to create."
  default     = 5
}

variable "os_image_id" {
  type        = "string"
  description = "The custom Azure image to use."
}

variable "size" {
  default     = "Standard_DS1_v2"
  type        = "string"
  description = "VM SKU to provision"
}

variable "disk_os_sku" {
  default     = "Premium_LRS"
  type        = "string"
  description = "Managed disk SKU for the OS disk"
}

variable "disk_data_sku" {
  default     = "Premium_LRS"
  type        = "string"
  description = "Managed disk SKU for the OS disk"
}

variable "disk_data_size_gb" {
  default     = 32
  type        = "string"
  description = "The size of the data disk"
}

variable "tags" {
  type        = "map"
  description = "Tags to be applied to resources."
}

locals {
  module_name = "${var.name}"
}
