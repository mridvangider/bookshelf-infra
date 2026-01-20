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

variable "admin_db_passowrd_key_name" {
  type        = string
  default     = "db-admin-password"
  description = "Name of the admin database password key in the key vault"
}