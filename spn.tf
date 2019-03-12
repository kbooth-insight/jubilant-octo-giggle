# Ideally we use Azure MSI for all of this, but at the time consul auto join and vault auto unseal need this SPN.
data "azurerm_subscription" "primary" {}

resource "random_string" "password" {
  length  = 32
  special = true
}

resource "azurerm_azuread_application" "main" {
  name = "${var.prefix}-spn"
}

resource "azurerm_azuread_service_principal" "main" {
  application_id = "${azurerm_azuread_application.main.application_id}"
}

resource "azurerm_azuread_service_principal_password" "main" {
  service_principal_id = "${azurerm_azuread_service_principal.main.id}"
  value                = "${random_string.password.result}"
  end_date             = "2020-01-01T00:00:00Z"
}

resource "azurerm_role_assignment" "main" {
  scope                = "${data.azurerm_subscription.primary.id}"
  role_definition_name = "Reader"
  principal_id         = "${azurerm_azuread_service_principal.main.id}"
}

data "azurerm_client_config" "current" {}

# set the SPN to be able to interact for autounseal
resource "azurerm_key_vault_access_policy" "autounseal" {
  key_vault_id = "${module.core.keyvault_id}"
  tenant_id    = "${data.azurerm_client_config.current.tenant_id}"
  object_id    = "${azurerm_azuread_service_principal.main.id}"

  key_permissions = [
    "backup",
    "create",
    "decrypt",
    "delete",
    "encrypt",
    "get",
    "import",
    "list",
    "purge",
    "recover",
    "restore",
    "sign",
    "unwrapKey",
    "update",
    "verify",
    "wrapKey",
  ]
}
