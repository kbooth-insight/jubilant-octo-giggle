variable "os" {
  default     = "Canonical:UbuntuServer:16.04-LTS:latest"
  type        = "string"
  description = "The Marketplace image information in the following format: Offer:Publisher:Sku:Version"
}
