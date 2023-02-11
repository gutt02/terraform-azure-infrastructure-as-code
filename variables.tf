locals {
  # detect OS
  # Directories start with "C:..." on Windows; All other OSs use "/" for root.
  is_windows = substr(pathexpand("~"), 0, 1) == "/" ? false : true
}

# curl ipinfo.io/ip
variable "agent_ip" {
  type = string

  description = "IP of the deployment agent."
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
    cidr             = "94.134.104.174/32"
    start_ip_address = "94.134.104.174"
    end_ip_address   = "94.134.104.174"
  }

  description = "List of client ips, can be empty."
}

variable "client_secret" {
  type        = string
  sensitive   = true
  description = "Client secret of the service principal."
}

variable "location" {
  type        = string
  default     = "westeurope"
  description = "Default Azure region, use Azure CLI notation."
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
    contact     = "sven.guttmann@bertelsmann.de"
    customer    = "Azure Cloud"
    environment = "Visual Studio Enterprise"
    project     = "Infrastructure as Code"
  }

  description = "Default tags for resources, only applied to resource groups"
}

variable "user_object_id" {
  type      = string
  sensitive = true

  description = "User object id, who needs access to the Key Vault."
}

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

variable "windows_virtual_machine_admin_username" {
  type        = string
  sensitive   = true
  description = "Windows Virtual Machine Admin User."
}

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
