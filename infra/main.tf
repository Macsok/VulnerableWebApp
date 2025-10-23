terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }

  required_version = ">= 1.1.0"
}

# Azure provider configuration
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  default_node_pool {
    name       = "default"
    vm_size    = var.node_vm_size
    node_count = var.node_count
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"
    ssh_key {
      key_data = var.ssh_public_key
    }
  }

  network_profile {
    network_plugin = "azure"
  }
}

# Static Public IP w node resource group (MC_*) - AKS ma tam domyślnie uprawnienia
resource "azurerm_public_ip" "aks_public_ip" {
  name                = "myAKSPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_kubernetes_cluster.aks.node_resource_group
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = var.dns_label
  
  tags = {
    purpose     = "aks-ingress-egress"
    environment = "demo"
    managed_by  = "terraform"
  }
  
  depends_on = [azurerm_kubernetes_cluster.aks]
}
