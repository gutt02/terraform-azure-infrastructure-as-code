locals {
  # detect OS
  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

variable "admin_username" {
  type        = string
  sensitive   = true
  description = "Linux Virtual Machine Admin User."
}

# curl ipinfo.io/ip
variable "agent_ip" {
  type        = string
  description = "IP of the deployment agent."
}

variable "automation_account_name" {
  type        = string
  description = "Name of the automation account."
}

# curl ipinfo.io/ip
variable "client_ip" {
  type = object({
    name             = string
    cidr             = string
    start_ip_address = string
    end_ip_address   = string
  })

  default = {
    name             = "ClientIP01"
    cidr             = "93.228.115.13/32"
    start_ip_address = "93.228.115.13"
    end_ip_address   = "93.228.115.13"
  }

  description = "List of client ips, can be empty."
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}

variable "key_vault_id" {
  type        = string
  description = "Id of the key vault to store the admin password."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Default Azure region, use Azure CLI notation."
}

variable "log_analytics_workspace_id" {
  type        = string
  description = "Id of the log analytics workspace used by the MicrosoftMonitoringAgent."
}

variable "log_analytics_workspace_primary_shared_key" {
  type        = string
  sensitive   = true
  description = "Primary shared key of the log analytics workspace used by the MicrosoftMonitoringAgent."
}

variable "mgmt_resource_group_name" {
  type        = string
  description = "Name of the management resource group."
}

variable "project" {
  type = object({
    customer    = string
    name        = string
    environment = string
  })

  default = {
    customer    = "azc"
    name        = "iac"
    environment = "vse"
  }

  description = "Project details, like customer name, environment, etc."
}

variable "recovery_services_vault_name" {
  type        = string
  description = "Name of the recovery service vault for the backup of the virtual machine."
}

variable "recovery_services_vault_id" {
  type        = string
  description = "Id of the recovery service vault for the backup of the virtual machine."
}

variable "subnet_id" {
  type        = string
  description = "Id of the subnet used for the private IP address of the virtual machine."
}

variable "tags" {
  type = object({
    created_by  = string
    contact     = string
    customer    = string
    environment = string
    project     = string
  })

  default = {
    created_by  = "vsp-base-msdn-sp-tf"
    contact     = "contact@me"
    customer    = "Azure Cloud"
    environment = "Visual Studio Enterprise"
    project     = "Infrastructure as Code"
  }

  description = "Default tags for resources, only applied to resource groups"
}

variable "linux_virtual_machine" {
  type = object({
    size = string

    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
  })

  default = {
    size = "Standard_B2ms"

    source_image_reference = {
      publisher = "Canonical"
      offer     = "UbuntuServer"
      sku       = "18.04-LTS"
      version   = "latest"
    }
  }

  description = "Linux Virtual Machine."
}
