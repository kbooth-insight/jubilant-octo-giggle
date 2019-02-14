variable "resource_group_name" {
  description = "The resource group to place module resources."
}

variable "name" {
  description = "A unique name that identifies the module."
  default     = "core"
}

variable "location" {
  description = "The Azure location to create all resources in."
}

variable "vnet_address_spacing" {
  type        = "list"
  description = "List of Address Spaces for the Virtual Network"
}

variable "subnet_address_prefixes" {
  type        = "list"
  description = "List of Subnet Address Prefixes. Each prefix will result in a new Subnet"
}

variable "username" {
  description = "The admin username for the Virtual Machines."
  default     = "cvstackadmin"
}

variable "public_key_openssh" {
  description = "The public SSH key."
}

variable "os" {
  default     = "Canonical:UbuntuServer:16.04.0-LTS:latest"
  type        = "string"
  description = "The Marketplace image information in the following format: Offer:Publisher:Sku:Version"
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

variable "key_vault_object_ids" {
  description = "The additonal object ids to add to the keyvault (Optional)"
  type        = "list"
  default     = []
}

variable "tags" {
  type        = "map"
  description = "Tags to be applied to resources."
}

data "azurerm_client_config" "current" {}

locals {
  module_name = "${var.name}"
}
