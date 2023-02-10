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

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment
resource "azurerm_resource_group_template_deployment" "this" {
  name                = "WindowsUpdate"
  resource_group_name = azurerm_resource_group.this.name

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

  deployment_mode = "Incremental"
}
