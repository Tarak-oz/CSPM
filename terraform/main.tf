data "azurerm_client_config" "current" {}

locals {
  name = "${var.prefix}-${var.environment}"
  tags = merge(var.tags, { environment = var.environment })
}

# ---------------------------------------------------------------------------
# Resource groups
# ---------------------------------------------------------------------------

resource "azurerm_resource_group" "hub" {
  name     = "rg-${local.name}-hub"
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "spoke" {
  name     = "rg-${local.name}-spoke"
  location = var.location
  tags     = local.tags
}

resource "azurerm_resource_group" "shared" {
  name     = "rg-${local.name}-shared"
  location = var.location
  tags     = local.tags
}

# ---------------------------------------------------------------------------
# Hub networking
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "hub" {
  name                = "vnet-${local.name}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = var.hub_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "hub" {
  name                 = "snet-${local.name}-hub"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.hub_subnet_prefix]
}

resource "azurerm_network_security_group" "hub" {
  name                = "nsg-${local.name}-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "hub" {
  subnet_id                 = azurerm_subnet.hub.id
  network_security_group_id = azurerm_network_security_group.hub.id
}

# ---------------------------------------------------------------------------
# Spoke networking
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-${local.name}-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = var.spoke_address_space
  tags                = local.tags
}

resource "azurerm_subnet" "spoke" {
  name                 = "snet-${local.name}-spoke"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.spoke_subnet_prefix]
}

resource "azurerm_network_security_group" "spoke" {
  name                = "nsg-${local.name}-spoke"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = local.tags
}

resource "azurerm_subnet_network_security_group_association" "spoke" {
  subnet_id                 = azurerm_subnet.spoke.id
  network_security_group_id = azurerm_network_security_group.spoke.id
}

# ---------------------------------------------------------------------------
# Hub <-> spoke peering
# ---------------------------------------------------------------------------

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-spoke"
  resource_group_name       = azurerm_resource_group.hub.name
  virtual_network_name      = azurerm_virtual_network.hub.name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-spoke-to-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = azurerm_virtual_network.hub.id
  allow_forwarded_traffic   = true
}

# ---------------------------------------------------------------------------
# Policy assignments (subscription scope)
# ---------------------------------------------------------------------------

data "azurerm_subscription" "current" {}

data "azurerm_policy_definition" "allowed_locations" {
  display_name = "Allowed locations"
}

resource "azurerm_subscription_policy_assignment" "allowed_locations" {
  name                 = "allowed-locations-${var.environment}"
  policy_definition_id = data.azurerm_policy_definition.allowed_locations.id
  subscription_id      = data.azurerm_subscription.current.id
  parameters = jsonencode({
    listOfAllowedLocations = {
      value = var.allowed_locations
    }
  })
}

data "azurerm_policy_definition" "require_tag" {
  display_name = "Require a tag on resource groups"
}

resource "azurerm_subscription_policy_assignment" "require_tag" {
  name                 = "require-tag-${var.environment}"
  policy_definition_id = data.azurerm_policy_definition.require_tag.id
  subscription_id      = data.azurerm_subscription.current.id
  parameters = jsonencode({
    tagName = {
      value = var.mandatory_tag_name
    }
  })
}

# ---------------------------------------------------------------------------
# RBAC
# ---------------------------------------------------------------------------

resource "azurerm_role_assignment" "this" {
  for_each             = var.rbac_assignments
  scope                = data.azurerm_subscription.current.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}
