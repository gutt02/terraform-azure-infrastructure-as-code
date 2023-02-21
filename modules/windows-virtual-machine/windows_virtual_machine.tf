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

# https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/offset
resource "time_offset" "this" {
  offset_days = 1
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group
resource "azurerm_resource_group" "this" {
  name     = "${var.project.customer}-${var.project.name}-${var.project.environment}-rg-wvm"
  location = var.location
  tags     = var.tags
}

# https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password
resource "random_password" "this" {
  length           = 16
  special          = true
  override_special = "_%@"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret
resource "azurerm_key_vault_secret" "this" {
  name         = var.admin_username
  value        = random_password.this.result
  key_vault_id = var.key_vault_id
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip
resource "azurerm_public_ip" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm-pip"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  allocation_method = "Dynamic"
  domain_name_label = "${var.project.customer}${var.project.name}${var.project.environment}wvm"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface
resource "azurerm_network_interface" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm-nic"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "IpConfig"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  admin_username = var.admin_username
  admin_password = random_password.this.result

  identity {
    type = "SystemAssigned"
  }

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    name                 = "${var.project.customer}${var.project.name}${var.project.environment}wvm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  size = var.windows_virtual_machine.size

  source_image_reference {
    publisher = var.windows_virtual_machine.source_image_reference.publisher
    offer     = var.windows_virtual_machine.source_image_reference.offer
    sku       = var.windows_virtual_machine.source_image_reference.sku
    version   = var.windows_virtual_machine.source_image_reference.version
  }

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

# Shutdown virtual machine automatically
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/dev_test_global_vm_shutdown_schedule
resource "azurerm_dev_test_global_vm_shutdown_schedule" "this" {
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  location           = var.location

  enabled = true

  daily_recurrence_time = "1700"
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/managed_disk
resource "azurerm_managed_disk" "this" {
  name                = "${azurerm_windows_virtual_machine.this.name}-datadisk"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  create_option        = "Empty"
  disk_size_gb         = "64"
  storage_account_type = "StandardSSD_LRS"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_data_disk_attachment
resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  managed_disk_id    = azurerm_managed_disk.this.id
  virtual_machine_id = azurerm_windows_virtual_machine.this.id
  lun                = "0"
  caching            = "ReadOnly"
}

# https://learn.microsoft.com/en-us/cli/azure/vm/run-command?view=azure-cli-latest#az-vm-run-command-invoke
# https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource
resource "null_resource" "mount_data_disk" {
  provisioner "local-exec" {
    command = "az vm run-command invoke --command-id RunPowerShellScript --name ${azurerm_windows_virtual_machine.this.name} -g ${azurerm_resource_group.this.name} --scripts @scripts/Add-DataDisk.ps1"
  }

  depends_on = [
    azurerm_virtual_machine_data_disk_attachment.this
  ]
}

# Install monitoring agent, needed for the automated patching
# https://learn.microsoft.com/de-de/azure/virtual-machines/extensions/oms-windows
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_machine_extension
resource "azurerm_virtual_machine_extension" "this" {
  name                       = "MicrosoftMonitoringAgent"
  virtual_machine_id         = azurerm_windows_virtual_machine.this.id
  publisher                  = "Microsoft.EnterpriseCloud.Monitoring"
  type                       = "MicrosoftMonitoringAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    "workspaceId" = "${var.log_analytics_workspace_id}"
  })

  protected_settings = jsonencode({
    "workspaceKey" = "${var.log_analytics_workspace_primary_shared_key}"
  })
}

# terraform is unable to destory (complete) this resource
# run it first then delete the item from the state file
# terraform state rm <resource_address>
# ATTENTION: Tests generate e-mails, SIC!
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/backup_protected_vm
# resource "azurerm_backup_protected_vm" "this" {
#   resource_group_name = azurerm_resource_group.this.name
#   recovery_vault_name = var.recovery_services_vault_name
#   source_vm_id        = azurerm_windows_virtual_machine.this.id
#   backup_policy_id    = "${var.recovery_services_vault_id}/backupPolicies/DefaultPolicy"

#   timeouts {
#     delete = "5m"
#   }

#   depends_on = [
#     azurerm_virtual_machine_extension.this,
#     null_resource.mount_data_disk
#   ]
# }


resource "time_sleep" "delay_template_deployment" {
  depends_on = [
    azurerm_virtual_machine_extension.this,
    null_resource.mount_data_disk
  ]

  create_duration = "120s"
}


# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_template_deployment
resource "azurerm_resource_group_template_deployment" "this" {
  name                = "windows-updates"
  resource_group_name = var.mgmt_resource_group_name

  deployment_mode = "Incremental"

  template_content = <<DEPLOY
  {
    "$schema": "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "resources": [
      {
          "apiVersion": "2017-05-15-preview",
          "type": "Microsoft.Automation/automationAccounts/softwareUpdateConfigurations",
          "name": "${var.automation_account_name}/windows-updates",
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
    time_sleep.delay_template_deployment
  ]
}
