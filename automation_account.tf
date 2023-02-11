locals {
  update_time            = "06:00"
  update_date            = substr(time_offset.this.rfc3339, 0, 10)
  update_timezone        = "UTC"
  update_max_hours       = "4"
  update_classifications = "Critical, Security, UpdateRollup, ServicePack, Definition, Updates"
  update_reboot_settings = "IfRequired"
  update_day             = "Thursday"
  update_occurrence      = "2"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/automation_account
resource "azurerm_automation_account" "this" {
  name                = "${var.project.customer}-${var.project.name}-${var.project.environment}-aacc"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  identity {
    type = "SystemAssigned"
  }

  sku_name = "Basic"
}

# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset
resource "time_offset" "this" {
  offset_days = 1
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
