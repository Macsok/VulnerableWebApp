# output "resource_group_name" {
#   value = azurerm_resource_group.rg.name
# }

# output "aks_name" {
#   value = azurerm_kubernetes_cluster.aks.name
# }

# output "kube_config_raw" {
#   value = azurerm_kubernetes_cluster.aks.kube_config_raw
#   sensitive = true
# }

# output "aks_public_ip_address" {
#   description = "Static public IP address for AKS (both ingress and egress traffic)"
#   value       = azurerm_public_ip.aks_public_ip.ip_address
# }

# output "aks_public_ip_id" {
#   description = "Resource ID of the AKS public IP"
#   value       = azurerm_public_ip.aks_public_ip.id
# }

# output "aks_public_ip_name" {
#   description = "Name of the public IP resource"
#   value       = azurerm_public_ip.aks_public_ip.name
# }

# output "aks_public_ip_fqdn" {
#   description = "Fully Qualified Domain Name for the public IP"
#   value       = azurerm_public_ip.aks_public_ip.fqdn
# }

# output "aks_node_resource_group" {
#   description = "Resource group where AKS nodes are deployed (MC_* resource group)"
#   value       = azurerm_kubernetes_cluster.aks.node_resource_group
# }

# output "appgw_public_ip_address" {
#   description = "Public IP address of the Application Gateway (WAF)"
#   value       = azurerm_public_ip.appgw_public_ip.ip_address
# }

# output "appgw_public_ip_fqdn" {
#   description = "FQDN of the Application Gateway (WAF) - use this to access your app"
#   value       = azurerm_public_ip.appgw_public_ip.fqdn
# }

# output "appgw_name" {
#   description = "Name of the Application Gateway (WAF)"
#   value       = azurerm_application_gateway.appgw.name
# }

# output "appgw_waf_enabled" {
#   description = "WAF is enabled and protecting the application"
#   value       = azurerm_application_gateway.appgw.waf_configuration[0].enabled
# }
