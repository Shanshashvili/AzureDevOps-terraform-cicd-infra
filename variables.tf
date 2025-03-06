variable "azure_subscription_id" {
  type        = string
  description = "Azure Subscription ID"
}

variable "azure_tenant_id" {
  type        = string
  description = "Azure Tenant ID"
}

variable "azure_devops_org_url" {
  type        = string
  description = "Azure DevOps Organization URL"
}

variable "azure_devops_pat" {
  type        = string
  description = "Azure DevOps Personal Access Token"
  sensitive   = true
}

variable "tf_state_resource_group" {
  type        = string
  description = "Resource group where the terraform state is located"
}

variable "tf_state_storage_account" {
  type        = string
  description = "Storage Account where the TF state is located"
}

variable "tf_state_container" {
  type        = string
  description = "Container where the TF state is located"
}

variable "tf_state_key" {
  type        = string
  description = "TF state key where the TF state is located"
}
