variable "project_name" {
  description = "Name of the project used in naming conventions"
  type        = string
  default     = "cloudapp"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Target deployment environment (dev, staging, prod)"
  type        = string
  default     = "prod"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "vnet_cidr" {
  description = "CIDR block address space for the Virtual Network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block address space for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "vm_size" {
  description = "Size / SKU of the Linux Virtual Machine"
  type        = string
  default     = "Standard_B2s"
}

variable "admin_username" {
  description = "Administrator username for VM SSH access"
  type        = string
  default     = "azureuser"
}

variable "os_disk_type" {
  description = "Storage tier for the OS managed disk"
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS"], var.os_disk_type)
    error_message = "OS disk type must be Standard_LRS, StandardSSD_LRS, or Premium_LRS."
  }
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in Gigabytes"
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30
    error_message = "OS disk size must be at least 30 GB."
  }
}

variable "os_disk_caching" {
  description = "Disk caching policy for OS disk (None, ReadOnly, ReadWrite)"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be None, ReadOnly, or ReadWrite."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  type        = map(string)
  default = {
    ManagedBy   = "Terraform"
    Project     = "azure-vm-app-deployment"
    Owner       = "DevOps"
  }
}
