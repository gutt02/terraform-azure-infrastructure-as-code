# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep
resource "time_sleep" "this" {
  depends_on = [
    azurerm_automation_account.this,
    azurerm_monitor_diagnostic_setting.this,
    azurerm_log_analytics_workspace.this,
    azurerm_log_analytics_linked_service.this,
    azurerm_log_analytics_solution.this,
    azurerm_windows_virtual_machine.this,
    azurerm_virtual_machine_extension.this,
  ]

  create_duration = "120s"
}

# Note: Disable softe delete of Recover Service Vault before destruction
# az backup vault backup-properties set --soft-delete-feature-state Disable --name azc-iac-vse-rsv
# Portal: Properties -> Security Settings -> Update -> Disable
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

  depends_on = [
    time_sleep.this
  ]
}

# terraform is unable to destory (complete) this resource
# run it first then delete the item from the state file
# terraform state rm <resource_address>
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm
resource "azurerm_backup_protected_vm" "this" {
  resource_group_name = azurerm_resource_group.this.name
  recovery_vault_name = azurerm_recovery_services_vault.this.name
  source_vm_id        = azurerm_windows_virtual_machine.this.id
  backup_policy_id    = "${azurerm_recovery_services_vault.this.id}/backupPolicies/DefaultPolicy"

  timeouts {
    delete = "5m"
  }

  depends_on = [
    azurerm_recovery_services_vault.this
  ]
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment
resource "azurerm_resource_group_template_deployment" "this" {
  name                = "WindowsUpdate"
  resource_group_name = azurerm_resource_group.this.name

  deployment_mode = "Incremental"

  template_content = <<DEPLOY
  {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "resources": [
      {
          "apiVersion": "2017-05-15-preview",
          "type": "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations",
          "name": "${azurerm_automation_account.this.name}/windows-updates",
          "properties": {
              "updateConfiguration": {
                  "operatingSystem": "Windows",
                  "duration": "PT${local.update_max_hours}H",
                  "windows": {
                      "excludedKbNumbers": [
                      ],
                      "includedUpdateClassifications": "${local.update_classifications}",
                      "rebootSetting": "${local.update_reboot_settings}"
                  },
                  "azureVirtualMachines": [
                      "${azurerm_windows_virtual_machine.this.id}"
                  ],
                  "nonAzureComputerNames": [
                  ]
              },
              "scheduleInfo": {
                  "frequency": "Month",
                  "startTime": "${local.update_date}T${local.update_time}:00",
                  "timeZone":  "${local.update_timezone}",
                  "interval": 1,
                  "advancedSchedule": {
                      "monthlyOccurrences": [
                          {
                            "occurrence": "${local.update_occurrence}",
                            "day": "${local.update_day}"
                          }
                      ]
                  }
              }
          }
      }
    ]
  }
  DEPLOY

  depends_on = [
    azurerm_backup_protected_vm.this
  ]
}
