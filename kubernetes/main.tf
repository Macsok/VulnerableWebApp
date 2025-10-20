# Konfiguracja dostawcy Azure
provider "azurerm" {
  features {}
}

# Konfiguracja dostawcy Kubernetes
# Używa danych wyjściowych z tworzonego klastra AKS do uwierzytelnienia
provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.aks.kube_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks.kube_config.0.cluster_ca_certificate)
}

# Tworzenie grupy zasobów w Azure
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Tworzenie klastra Azure Kubernetes Service (AKS)
resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.cluster_name}-dns"
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name       = "default"
    node_count = var.node_count
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# Wdrożenie manifestów Kubernetes z folderu 'manifests'
# Ta pętla odczytuje wszystkie pliki .yaml z folderu i tworzy dla nich zasób
resource "kubernetes_manifest" "app" {
  for_each = fileset("manifests", "*.yaml")
  manifest = yamldecode(file("manifests/${each.value}"))
}
