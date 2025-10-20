variable "resource_group_name" {
  description = "Nazwa grupy zasobów w Azure."
  type        = string
  default     = "aks-terraform-rg"
}

variable "location" {
  description = "Region Azure, w którym zostaną utworzone zasoby."
  type        = string
  default     = "West Europe"
}

variable "cluster_name" {
  description = "Nazwa klastra AKS."
  type        = string
  default     = "my-aks-cluster"
}

variable "kubernetes_version" {
  description = "Wersja Kubernetes dla klastra AKS."
  type        = string
  default     = "1.29.2"
}

variable "node_count" {
  description = "Liczba węzłów (maszyn wirtualnych) w klastrze."
  type        = number
  default     = 2
}
