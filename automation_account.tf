resource "azurerm_automation_account" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-aacc"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  sku_name = "Basic"
}
