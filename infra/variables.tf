variable "subscription_id" {
  description = "Azure subscription id"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group to create"
  type        = string
  default     = "vulnerable-web-app-rg"
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "switzerlandnorth"
}

variable "acr_name" {
  description = "Name for Azure Container Registry (must be globally unique)"
  type        = string
  default     = "vulnerable-webapp-registry"
}

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "vulnerable-webapp-aks"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "vulnerable-webapp-aks"
}

variable "node_vm_size" {
  description = "Size for AKS nodes"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  default     = 2
}

variable "ssh_public_key" {
  description = "SSH public key content for AKS nodes"
  type        = string
}
