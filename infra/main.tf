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

# Virtual Network dla Application Gateway
resource "azurerm_virtual_network" "appgw_vnet" {
  name                = "appgw-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.254.0.0/16"]
  
  tags = {
    purpose     = "application-gateway"
    environment = "demo"
    managed_by  = "terraform"
  }
}

# Subnet dla Application Gateway
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.appgw_vnet.name
  address_prefixes     = ["10.254.0.0/24"]
}

# Public IP dla Application Gateway
resource "azurerm_public_ip" "appgw_public_ip" {
  name                = "appgw-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "${var.dns_label}-waf"
  
  tags = {
    purpose     = "application-gateway-waf"
    environment = "demo"
    managed_by  = "terraform"
  }
}

# Application Gateway z WAF
resource "azurerm_application_gateway" "appgw" {
  name                = "appgw-waf"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  
  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.appgw_subnet.id
  }
  
  frontend_port {
    name = "https-port"
    port = 443
  }
  
  frontend_port {
    name = "http-port"
    port = 80
  }
  
  frontend_ip_configuration {
    name                 = "appgw-frontend-ip"
    public_ip_address_id = azurerm_public_ip.appgw_public_ip.id
  }
  
  # SSL Certificate (z pliku pfx)
  ssl_certificate {
    name     = "ssl-certificate"
    data     = filebase64("${path.module}/../kubernetes/certificate.pfx")
    password = var.ssl_cert_password
  }
  
  backend_address_pool {
    name  = "aks-backend-pool"
    fqdns = [azurerm_public_ip.aks_public_ip.fqdn]
  }
  
  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
    
    probe_name = "health-probe"
  }
  
  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = "/"
    host                = azurerm_public_ip.aks_public_ip.fqdn
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
  }
  
  # HTTP Listener (redirect do HTTPS)
  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }
  
  # HTTPS Listener
  http_listener {
    name                           = "https-listener"
    frontend_ip_configuration_name = "appgw-frontend-ip"
    frontend_port_name             = "https-port"
    protocol                       = "Https"
    ssl_certificate_name           = "ssl-certificate"
  }
  
  # Request routing rule dla HTTPS
  request_routing_rule {
    name                       = "https-routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "https-listener"
    backend_address_pool_name  = "aks-backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }
  
  # Redirect rule dla HTTP -> HTTPS
  redirect_configuration {
    name                 = "http-to-https-redirect"
    redirect_type        = "Permanent"
    target_listener_name = "https-listener"
    include_path         = true
    include_query_string = true
  }
  
  request_routing_rule {
    name                        = "http-redirect-rule"
    rule_type                   = "Basic"
    http_listener_name          = "http-listener"
    redirect_configuration_name = "http-to-https-redirect"
    priority                    = 200
  }
  
  # SSL Policy - wymuszenie TLS 1.2+
  ssl_policy {
    policy_type = "Predefined"
    policy_name = "AppGwSslPolicy20220101S"
  }
  
  # WAF Configuration
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention"
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
    
    disabled_rule_group {
      rule_group_name = "REQUEST-920-PROTOCOL-ENFORCEMENT"
      rules           = []
    }
    
    file_upload_limit_mb     = 100
    max_request_body_size_kb = 128
    request_body_check       = true
  }
  
  tags = {
    purpose     = "waf-protection"
    environment = "demo"
    managed_by  = "terraform"
  }
  
  depends_on = [
    azurerm_public_ip.appgw_public_ip,
    azurerm_subnet.appgw_subnet
  ]
}
