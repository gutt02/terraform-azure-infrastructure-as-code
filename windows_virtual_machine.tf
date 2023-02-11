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
    subnet_id                     = azurerm_subnet.this.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.this.id
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/windows_virtual_machine
resource "azurerm_windows_virtual_machine" "this" {
  name                = "${var.project.customer}${var.project.name}${var.project.environment}wvm"
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name

  admin_username = var.windows_virtual_machine_admin_username
  # admin_password = var.windows_virtual_machine_admin_password
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
    "workspaceId" = "${azurerm_log_analytics_workspace.this.workspace_id}"
  })

  protected_settings = jsonencode({
    "workspaceKey" = "${azurerm_log_analytics_workspace.this.primary_shared_key}"
  })
}
