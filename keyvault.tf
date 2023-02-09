# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-kv"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  enable_rbac_authorization = true
  sku_name                  = "standard"
  tenant_id                 = data.azurerm_client_config.client_config.tenant_id

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = [var.client_ip.cidr]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "this" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.client_config.object_id
}

resource "azurerm_role_assignment" "this2" {
  scope                = azurerm_key_vault.this.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.user_object_id
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "this" {
  name         = var.windows_virtual_machine_admin_username
  value        = random_password.this.result
  key_vault_id = azurerm_key_vault.this.id

  depends_on = [
    azurerm_role_assignment.this
  ]
}
