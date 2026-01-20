variable "azure_client_id" {
  type        = string                              # The type of the variable, in this case a string
  description = "Azure Service Principle Client Id" # Description of what this variable represents
}

variable "azure_client_secret" {
  type        = string                                  # The type of the variable, in this case a string
  description = "Azure Service Principle Client Secret" # Description of what this variable represents
  sensitive   = true
}

variable "azure_tenant_id" {
  type        = string            # The type of the variable, in this case a string
  description = "Azure Tenant Id" # Description of what this variable represents
}

variable "azure_subscription_id" {
  type        = string                  # The type of the variable, in this case a string
  description = "Azure Subscription Id" # Description of what this variable represents
}
