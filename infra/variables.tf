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

variable "aks_name" {
  description = "AKS cluster name"
  type        = string
  default     = "vulnerableWebappAKS"
}

variable "dns_prefix" {
  description = "DNS prefix for AKS"
  type        = string
  default     = "vulnerableWebappAKS"
}

variable "node_vm_size" {
  description = "Size for AKS nodes"
  type        = string
  default     = "standard_b2s"
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  default     = 2
}

variable "ssh_public_key" {
  description = "SSH public key content for AKS nodes"
  type        = string
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDModSGulxjkyP2uC/AjMFn6Ij/VHS3o3GJuAViw+TUhfRZrLCpHtyevkoSLPJC2HkDS/bsXwE5hhpZY9xXyfPW9ngCeFvRKYVETq+Nq233sW+3Zjil6C5EaCdqhlsrQKxphpIWYZb1hMKVjUaMp7VprvT9lUj59mhZMQd61JlkEKoFwuwdu4OoGCwSUt98YOW4YvAiUh+qBqb4cphD51fKYeypDKB6uy/24mUgSz88L+z4XYJqYZCNVUavtk8m993qwqGs/v6LI649hcXoSzldHgY0HNULuPXwgWEJHQgFsetP+k9bf1/lFGOikcHVTKsde7VUrTwut7TyUYcy7jhNuYd5xrB46jK99vHlJSclkYpUfLLo1uiv1MuNoAsevtN4s4cnz7kbQYg1nFJyIr3ILBQvcO4R6artm6Z2wVaYssvtsoGCHVTD+AbwvSets5zEpTY7+RfIwTmpukKH3mtrreKExBpGXNzyP3v8hwgX/Rr4RA0A2a7LDc6kaFLr4/JB7HjUqIVW4noDUVG/M1BwF4qAhvMWOMClBUpTmb5mGrXP6JsVm+I0zH4kyXOAFS57NWwT1XG1hhqIqZ3bZDo+W6Hn9lbDo0DL8qrNAXyHcxhPHxi/NsrjPteWOznKcbXN+rDp3+X0k8SxeFrOcYk9taWoCkPUe8TkHqUCtR6h1Q== user@host"
}

variable "dns_label" {
  description = "DNS label for the public IP address (creates <dns_label>.<region>.cloudapp.azure.com)"
  type        = string
  default     = "vulnerable-webapp"
}
