variable "location" {
  type        = string
  default     = "switzerlandnorth"
  description = "Location of the resources"
}

variable "infra_rg_name" {
  type        = string
  default     = "infra"
  description = "Name of the infrastructure resource group"
}

variable "infra_kv_name" {
  type        = string
  default     = "rg-infra-key-vault"
  description = "Name of the infrastructure key vault"
}

variable "bookshelf_db_name" {
  type        = string
  default     = "bookshelf_db"
  description = "Name of the bookshelf database"
}

variable "bookshelf_db_admin" {
  type        = string
  default     = "bookshelf_db_admin"
  description = "Username for the bookshelf db admin"
}

variable "bookshelf_db_admin_password_key_name" {
  type        = string
  default     = "bookshelf-db-admin-password"
  description = "Name of the admin database password key in the key vault"
}

variable "bookshelf_db_svc_user" {
  type        = string
  default     = "svc_bookshelf"
  description = "Name of the bookshelf database user"
}

variable "application_port" {
  type        = number
  default     = 80
  description = "HTTP port for the tomcat server"
}

variable "main_acr_name" {
  type        = string
  default     = "maincr"
  description = "Name of the main container registry"
}