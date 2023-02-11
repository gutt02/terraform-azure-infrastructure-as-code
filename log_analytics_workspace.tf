# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace
resource "azurerm_log_analytics_workspace" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-la"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  sku = "PerGB2018"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_linked_service
resource "azurerm_log_analytics_linked_service" "this" {
  resource_group_name = azurerm_resource_group.this.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  read_access_id      = azurerm_automation_account.this.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_solution
resource "azurerm_log_analytics_solution" "this" {
  solution_name       = "Updates"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  workspace_resource_id = azurerm_log_analytics_workspace.this.id
  workspace_name        = azurerm_log_analytics_workspace.this.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Updates"
  }
}
