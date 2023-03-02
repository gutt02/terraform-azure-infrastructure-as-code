# Terraform - Azure - Infrastructure as Code

## Table of Contents

* [Introduction](#introduction)
* [Pre-Requirements](#pre-requirements)
* [Modules](#modules)
  * [Shared](#shared)
  * [Windows Virtual Machine](#windows-virtual-machine)
  * [Linux Virtual Machine](#linux-virtual-machine)
* [GitHub Actions](#github-actions)

## Introduction

This is a collection of Terraform scripts that show how to create Azure resources.

## Pre-Requirements

* Service Principal
* Remote Backend
* [terraform-azure-setup-remote-backed](https://github.com/gutt02/terraform-azure-setup-remote-backend)

## Modules

### Shared

#### Azure Resources

* Resource Group
* Azure Automation
* Azure Virtual Network
* Key Vault
* Log Analytics Workspace
* Recovery Service Vault

#### Variables

```hcl
variable "agent_ip" {
  type        = string
  description = "IP of the deployment agent."
}
```

```hcl
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
    cidr             = "94.134.104.174/32"
    start_ip_address = "94.134.104.174"
    end_ip_address   = "94.134.104.174"
  }

  description = "List of client ips, can be empty."
}
```

```hcl
variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}
```

```hcl
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Default Azure region, use Azure CLI notation."
}
```

```hcl
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
```

```hcl
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
```

```hcl
variable "user_object_id" {
  type        = string
  description = "User object id, who needs access to the Key Vault."
}
```

```hcl
variable "virtual_network" {
  type = object({
    address_space = string

    subnets = map(object({
      name          = string
      address_space = string
    }))
  })

  default = {
    address_space = "192.168.255.0/27"

    subnets = {
      virtual_machine = {
        name          = "virtual-machine"
        address_space = "192.168.255.0/28"
      }
    }
  }

  description = "VNET destails."
}
```

### Windows Virtual Machine

#### Azure Resources

* Public IP
* Azure Network Interface
* Windows Virtual Machine, authentication with username and password
* Managed Disk
* Disk Attachment
* Automated Shutdown
* Automated Backup
* Automated Patching
* Add data disk with PowerShell script

#### Variables

```hcl
variable "admin_username" {
  type        = string
  sensitive   = true
  description = "Windows Virtual Machine Admin User."
}
```

```hcl
# curl ipinfo.io/ip
variable "agent_ip" {
  type        = string
  description = "IP of the deployment agent."
}
```

```hcl
variable "automation_account_name" {
  type        = string
  description = "Name of the automation account."
}
```

```hcl
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
    cidr             = "94.134.104.174/32"
    start_ip_address = "94.134.104.174"
    end_ip_address   = "94.134.104.174"
  }

  description = "List of client ips, can be empty."
}
```

```hcl
variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}
```

```hcl
variable "key_vault_id" {
  type        = string
  description = "Id of the key vault to store the admin password."
}
```

```hcl
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Default Azure region, use Azure CLI notation."
}
```

```hcl
variable "log_analytics_workspace_id" {
  type        = string
  description = "Id of the log analytics workspace used by the MicrosoftMonitoringAgent."
}
```

```hcl
variable "log_analytics_workspace_primary_shared_key" {
  type        = string
  sensitive   = true
  description = "Primary shared key of the log analytics workspace used by the MicrosoftMonitoringAgent."
}
```

```hcl
variable "mgmt_resource_group_name" {
  type        = string
  description = "Name of the management resource group."
}
```

```hcl
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
```

```hcl
variable "recovery_services_vault_name" {
  type        = string
  description = "Name of the recovery service vault for the backup of the virtual machine."
}
```

```hcl
variable "recovery_services_vault_id" {
  type        = string
  description = "Id of the recovery service vault for the backup of the virtual machine."
}
```

```hcl
variable "subnet_id" {
  type        = string
  description = "Id of the subnet used for the private IP address of the virtual machine."
}
```

```hcl
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
    contact     = "contact@mede"
    customer    = "Azure Cloud"
    environment = "Visual Studio Enterprise"
    project     = "Infrastructure as Code"
  }

  description = "Default tags for resources, only applied to resource groups"
}
```

```hcl
variable "windows_virtual_machine" {
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
      publisher = "MicrosoftWindowsDesktop"
      offer     = "Windows-11"
      sku       = "win11-22h2-pro"
      version   = "latest"
    }
  }

  description = "Windows Virtual Machine."
}
```

### Linux Virtual Machine

#### Azure Resources

* Public IP
* Azure Network Interface
* Linux Virtual Machine, authentication with username and ssh-key
* Managed Disk
* Disk Attachment
* Automated Shutdown
* Automated Backup
* Automated Patching
* Disk partioning with Shell script

#### Variables

```hcl
variable "admin_username" {
  type        = string
  sensitive   = true
  description = "Linux Virtual Machine Admin User."
}
```

```hcl
# curl ipinfo.io/ip
variable "agent_ip" {
  type        = string
  description = "IP of the deployment agent."
}
```

```hcl
variable "automation_account_name" {
  type        = string
  description = "Name of the automation account."
}
```

```hcl
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
```

```hcl
variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}
```

```hcl
variable "key_vault_id" {
  type        = string
  description = "Id of the key vault to store the admin password."
}
```

```hcl
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Default Azure region, use Azure CLI notation."
}
```

```hcl
variable "log_analytics_workspace_id" {
  type        = string
  description = "Id of the log analytics workspace used by the MicrosoftMonitoringAgent."
}
```

```hcl
variable "log_analytics_workspace_primary_shared_key" {
  type        = string
  sensitive   = true
  description = "Primary shared key of the log analytics workspace used by the MicrosoftMonitoringAgent."
}
```

```hcl
variable "mgmt_resource_group_name" {
  type        = string
  description = "Name of the management resource group."
}
```

```hcl
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
```

```hcl
variable "recovery_services_vault_name" {
  type        = string
  description = "Name of the recovery service vault for the backup of the virtual machine."
}
```

```hcl
variable "recovery_services_vault_id" {
  type        = string
  description = "Id of the recovery service vault for the backup of the virtual machine."
}
```

```hcl
variable "subnet_id" {
  type        = string
  description = "Id of the subnet used for the private IP address of the virtual machine."
}
```

```hcl
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
```

```hcl
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
```

## GitHub Actions

## shared_terraform_apply_main.yml

Main YAML pipeline to deploy shared services.

### Inputs

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| RUNS_ON | string | true | ubuntu-latest | Actions Runner, either ubuntu-latest or self-hosted. |
| LOCATION | string | true | westeurope | Azure Region |
| CLIENT_IP | string | true | 94.134.104.161 | Client IP |
| INITIAL | string | true | no | Initial Deployment (yes or no). | 

## shared_terraform_apply.yml

Callable YAML pipline to deploy shared services.

### Inputs

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| RUNS_ON | string | true | ubuntu-latest | Actions Runner, either ubuntu-latest or self-hosted |
| MODULE | string | true | - | Module to be deployed. |
| LOCATION | string | true | westeurope | Azure Region |
| CLIENT_IP | string | true | 94.134.104.161 | Client IP |
| INITIAL | string | true | no | Initial Deployment (yes or no) | 

### Secrets

| Secret | Required |
| --- | --- |
| CLIENT_ID | true |
| CLIENT_SECRET | true |
| TENANT_ID | true |

## shared_terraform_output.yml

Callable YAML pipeline to export output values.

### Inputs

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| RUNS_ON | string | true | ubuntu-latest | Actions Runner, either ubuntu-latest or self-hosted |
| MODULE | string | true | - | Module to be deployed. |
| LOCATION | string | true | westeurope | Azure Region |
| CLIENT_IP | string | true | 94.134.104.161 | Client IP |
| INITIAL | string | true | no | Initial Deployment (yes or no) | 

### Secrets

| Secret | Required | Description |
| --- | --- | --- |
| CLIENT_ID | true | Client Id of the service principal |
| CLIENT_SECRET | true | Client secret of the service principal |
| TENANT_ID | true | | Tenat Id

### Outputs

| Output | Description |
| --- | --- |
| AUTOMATION_ACCOUNT_NAME | Name of the automation account. |
| KEY_VAULT_ID | Id of the key vault to store the admin password. |
| LOG_ANALYTICS_WORKSPACE_ID | Id of the log analytics workspace used by the MicrosoftMonitoringAgent. |
| LOG_ANALYTICS_WORKSPACE_PRIMARY_SHARED_KEY | Primary shared key of the log analytics workspace used by the MicrosoftMonitoringAgent. |
| MGMT_RESOURCE_GROUP_NAME | Name of the management resource group. |
| RECOVERY_SERVICES_VAULT_ID | Id of the recovery service vault for the backup of the virtual machine. |
| RECOVERY_SERVICES_VAULT_NAME | Name of the recovery service vault for the backup of the virtual machine. |
| SUBNET_ID | Id of the subnet used for the private IP address of the virtual machine. |

## module_terraform_apply_main.yml

Main YAML pipeline to deploy a module.

### Inputs

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| RUNS_ON | string | true | ubuntu-latest | Actions Runner, either ubuntu-latest or self-hosted. |
| MODULE | string | true | linux-virtual-machine | Module to be deployed. |
| LOCATION | string | true | westeurope | Azure Region |
| CLIENT_IP | string | true | 94.134.104.161 | Client IP |
| INITIAL | string | true | no | Initial Deployment (yes or no). | 

## module_terraform_apply.yml

Callable YAML pipline to deploy a module.

### Inputs

| Parameter | Type | Required | Default | Description |
| --- | --- | --- | --- | --- |
| RUNS_ON | string | true | ubuntu-latest | Actions Runner, either ubuntu-latest or self-hosted |
| MODULE | string | true | - | Module to be deployed. |
| LOCATION | string | true | westeurope | Azure Region |
| CLIENT_IP | string | true | 94.134.104.161 | Client IP |
| INITIAL | string | true | no | Initial Deployment (yes or no) | 
| AUTOMATION_ACCOUNT_NAME | string | true | no | Name of the automation account. |
| KEY_VAULT_ID | string | true | no | Id of the key vault to store the admin password. |
| LOG_ANALYTICS_WORKSPACE_ID | string | true | no | Id of the log analytics workspace used by the MicrosoftMonitoringAgent. |
| LOG_ANALYTICS_WORKSPACE_PRIMARY_SHARED_KEY | string | true | no | Primary shared key of the log analytics workspace used by the MicrosoftMonitoringAgent. |
| MGMT_RESOURCE_GROUP_NAME | string | true | no | Name of the management resource group. |
| RECOVERY_SERVICES_VAULT_ID | string | true | no | Id of the recovery service vault for the backup of the virtual machine. |
| RECOVERY_SERVICES_VAULT_NAME | string | true | no | Name of the recovery service vault for the backup of the virtual machine. |
| SUBNET_ID | string | true | no | Id of the subnet used for the private IP address of the virtual machine. |

### Secrets

| Secret | Required |
| --- | --- |
| CLIENT_ID | true |
| CLIENT_SECRET | true |
| TENANT_ID | true |
