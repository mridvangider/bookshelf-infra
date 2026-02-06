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

variable "subnet_name" {
  type        = string
  description = "Name of the subnet to host Azure Postgres Flexible servers"
}

variable "vnet_name" {
  type        = string
  description = "Name of the virtual network to host Azure Postgres Flexible servers"
}

variable "admin_password" {
  ephemeral   = true
  type        = string
  description = "Password of the postgres admin user"
}

variable "admin_password_version" {
  type        = number
  description = "Version of the password of the postgres admin user"
}

variable "admin_username" {
  type        = string
  description = "Postgres admin username"
  default     = "bookshelf_db_admin"
}

variable "db_name" {
  type        = string
  default     = "bookshelf_db"
  description = "Name of the bookshelf database"
}

variable "pg_version" {
  type        = string
  default     = "17"
  description = "Postgresql Version"
}
