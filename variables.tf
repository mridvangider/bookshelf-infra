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

variable "db_entra_admin_object_id" {
  type        = string
  description = "Id of the Entra Principal for the DB adminstrator"
}

variable "db_entra_admin_name" {
  type        = string
  description = "Name of the Entra Principal for the DB adminstrator"
}

variable "db_entra_admin_type" {
  type        = string
  description = "Type of the Entra Principal for the DB adminstrator"
}

variable "db_admin_password" {
  type        = string
  description = "Password for the postgres administrator"
  sensitive   = true
  ephemeral   = true
}

variable "db_admin_password_version" {
  type        = number
  description = "Version of the password for the postgres administrator"
}

variable "deployment_principals_object_id" {
  type        = string
  description = "Object id of the deployment principals group"
}