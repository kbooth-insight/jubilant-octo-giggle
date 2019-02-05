variable "prefix" {
  description = "Unique affix to avoid resource duplication."
  default = "hashi"
}

locals {
  common_tags = {
    environment = "${var.prefix}-cvstack"
    DoNotDelete = "yes"
  }
}

variable "location" {
  description = "The Azure location to which to deploy."
  default     = "East US"
}

variable "vault_image_id" {
  description = "The Image ID to use for the base VM for Vault."
}

variable "consul_image_id" {
  description = "The Image ID to use for the base VM for Consul."
}

variable "consul_count" {
  description = "The number of Consul nodes to deploy."
  default = "3"
}

variable "vault_count" {
  description = "The number of Vault nodes to deploy."
  default = "3"
}

variable "consul_machine_size" {
  description = "The machine size to use for Consul."
  default = "Standard_DS1_v2"
}

variable "vault_machine_size" {
  description = "The machine size to use for Vault."
  default = "Standard_DS1_v2"
}
