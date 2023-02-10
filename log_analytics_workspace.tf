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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/monitor_diagnostic_categories
data "azurerm_monitor_diagnostic_categories" "this" {
  resource_id = azurerm_automation_account.this.id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                           = "Update"
  target_resource_id             = azurerm_automation_account.this.id
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  log_analytics_destination_type = "AzureDiagnostics"

  dynamic "enabled_log" {
    for_each = data.azurerm_monitor_diagnostic_categories.this.log_category_types

    content {
      category = enabled_log.key

      retention_policy {
        enabled = false
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/recovery_services_vault
resource "azurerm_recovery_services_vault" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-rsv"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  sku = "Standard"

  lifecycle {
    ignore_changes = [
      soft_delete_enabled
    ]
  }
}
