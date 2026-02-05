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

variable "agent_admin_user" {
  type        = string
  default     = "azureuser"
  description = "Name of the agent user"
}

variable "agent_subnet_id" {
  type        = string
  description = "Id of the subnet to host the agent"
}

variable "agent_vm_size" {
  type        = string
  default     = "Standard_B1ms"
  description = "Size of the agent vm"
}

variable "agent_admin_pubkey_name" {
  type        = string
  description = "Name of public key for admin user of agent"
}

variable "bookshelf_db_admin_group_object_id" {
  type        = string
  description = "Object id of the bookshelf db admin group"
}