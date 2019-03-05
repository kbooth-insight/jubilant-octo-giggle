variable "resource_group_name" {
  description = "The resource group to put the image gallery in"
  default     = "hashistack-images-rg"
}

variable "location" {
  description = "The Azure location to which to deploy."
  default     = "eastus"
}

variable "secondary_location" {
  description = "The Azure location to which to replcate the image"
  default     = "centralus"
}

variable "prefix" {
  description = "Unique affix to avoid resource duplication."
  default     = "hashistack"
}

variable "publisher" {
  default = "hashiPS"
}

variable "offer" {
  default = "consul-vault"
}

variable "sku" {
  default = "enterprise"
}

variable "images_ids" {
  type        = "list"
  description = "List of Azure Managed Images to store in the gallery"
}

locals {
  common_tags = {
    environment = "${var.prefix}-cvstack"
    DoNotDelete = "yes"
  }
}
