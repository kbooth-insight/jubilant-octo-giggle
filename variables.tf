variable "location" {
  description = "The Azure location to which to deploy."
  default     = "eastus"
}

variable "prefix" {
  description = "Unique affix to avoid resource duplication."
  default     = "hashi"
}

variable "vnet_address_spacing" {
  type        = "list"
  description = "List of Address Spaces for the Virtual Network"
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  type        = "list"
  description = "List of Subnet Address Prefixes. Each prefix will result in a new Subnet"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "consul_encrypt" {
  description = "The encrypt key deployed to the consul nodes."
}

variable "vault_image_id" {
  description = "The Image ID to use for the base VM for Vault."
}

variable "consul_image_id" {
  description = "The Image ID to use for the base VM for Consul."
}

variable "domain" {
  description = "The domain"
  default     = "test.com"
}

variable "consul_count" {
  description = "The number of Consul nodes to deploy."
  default     = "5"
}

variable "vault_count" {
  description = "The number of Vault nodes to deploy."
  default     = "3"
}

variable "consul_machine_size" {
  description = "The machine size to use for Consul."
  default     = "Standard_DS1_v2"
}

variable "vault_machine_size" {
  description = "The machine size to use for Vault."
  default     = "Standard_DS1_v2"
}

variable "key_vault_object_ids" {
  description = "The additonal object ids to add to the keyvault (Optional)"
  type        = "list"
  default     = []
}

variable "vault_unseal_client_id" {
  # Currently cant source this from the data.azurerm_client_config
  description = "Client secret for autounseal."
}

locals {
  common_tags = {
    environment = "${var.prefix}-cvstack"
    DoNotDelete = "yes"
  }
}

output "public-fqdn" {
  value = "${module.core.public-fqdn}"
}

output "cluster1-consul-ips" {
  value = "${module.cluster_1.consul-ips}"
}

output "cluster1-vault-ips" {
  value = "${module.cluster_1.vault-ips}"
}

# output "cluster2-consul-ips" {
#   value = "${module.cluster_2.consul-ips}"
# }


# output "cluster2-vault-ips" {
#   value = "${module.cluster_2.vault-ips}"
# }

