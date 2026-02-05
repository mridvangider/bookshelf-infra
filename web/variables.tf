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

variable "vnet_name" {
  type        = string
  description = "Name of the vnet to host the application"
}

variable "deployment_principals_object_id" {
  type        = string
  description = "Object id of the deployment principals group"
}

variable "app_subnet_name" {
  type        = string
  description = "Name of the subnet to host app service"
}

variable "endpoint_subnet_name" {
  type        = string
  default     = "default"
  description = "Name of the subnet to contain private endpoint to the app service"
}