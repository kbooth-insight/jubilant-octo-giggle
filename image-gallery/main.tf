resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_shared_image_gallery" "main" {
  name                = "${var.prefix}_image_gallery"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  description         = "Images for Hashicorp stack"

  tags = "${local.common_tags}"
}

resource "azurerm_shared_image" "main" {
  name                = "${var.prefix}-consul-vault-image"
  gallery_name        = "${azurerm_shared_image_gallery.main.name}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  location            = "${azurerm_resource_group.main.location}"
  os_type             = "Linux"

  identifier {
    publisher = "${var.publisher}"
    offer     = "${var.offer}"
    sku       = "${var.sku}"
  }
}

resource "azurerm_shared_image_version" "main" {
  name                = "0.0.${count.index + 1}"
  gallery_name        = "${azurerm_shared_image.main.gallery_name}"
  image_name          = "${azurerm_shared_image.main.name}"
  resource_group_name = "${azurerm_shared_image.main.resource_group_name}"
  location            = "${azurerm_shared_image.main.location}"
  managed_image_id    = "${var.images_ids[count.index]}"
  count               = "${length(var.images_ids)}"

  target_region {
    name                   = "${azurerm_resource_group.main.location}"
    regional_replica_count = "1"
  }

  target_region {
    name                   = "${var.secondary_location}"
    regional_replica_count = "1"
  }
}

output "consul-vault-images" {
  value = "${azurerm_shared_image_version.main.*.id}"
}
