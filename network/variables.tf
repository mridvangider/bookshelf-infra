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

variable "vnet_ip_range" {
  type        = string
  default     = "10.0.0.0/16"
  description = "IP Address space for the virtual network"
}

variable "bastion_subnet_ip_range" {
  type        = string
  default     = "10.0.0.0/16"
  description = "IP Address space for the virtual network"
}

variable "default_subnet_ip_range" {
  type        = string
  default     = "10.1.0.0/16"
  description = "IP Address space for the default subnet"
}

variable "db_subnet_ip_range" {
  type        = string
  default     = "10.2.0.0/16"
  description = "IP Address space for the db subnet"
}

variable "app_subnet_ip_range" {
  type        = string
  default     = "10.3.0.0/16"
  description = "IP Address space for the app"
}