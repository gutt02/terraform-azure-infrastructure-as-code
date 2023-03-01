output "automation_account_name" {
  value = azurerm_automation_account.this.name
}

output "key_vault_id" {
  value = azurerm_key_vault.this.id
}

output "log_analytics_workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}

output "log_analytics_workspace_primary_shared_key" {
  value     = azurerm_log_analytics_workspace.this.primary_shared_key
  sensitive = true
}

output "mgmt_resource_group_name" {
  value = azurerm_resource_group.mgmt.name
}

output "recovery_services_vault_id" {
  value = azurerm_recovery_services_vault.this.id
}

output "recovery_services_vault_name" {
  value = azurerm_recovery_services_vault.this.name
}

output "subnet_id" {
  value = azurerm_subnet.this.id
}
