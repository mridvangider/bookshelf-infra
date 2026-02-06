variable "resource_group_name" {
  type        = string
  default     = "bookshelf"
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "switzerlandnorth"
  description = "Azure region to use for all the resources"
}

variable "admin_user" {
  type        = string
  default     = "azureuser"
  description = "Name of the admin user"
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet to host the agent"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network where the subnet is located"
}

variable "vm_size" {
  type        = string
  default     = "Standard_B1ms"
  description = "Size of the agent vm"
}

variable "admin_pubkey_name" {
  type        = string
  description = "Name of public key for admin user of agent"
}
