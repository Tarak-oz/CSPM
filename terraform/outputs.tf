output "hub_resource_group_name" {
  value = azurerm_resource_group.hub.name
}

output "spoke_resource_group_name" {
  value = azurerm_resource_group.spoke.name
}

output "shared_resource_group_name" {
  value = azurerm_resource_group.shared.name
}

output "hub_vnet_id" {
  value = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  value = azurerm_virtual_network.spoke.id
}
