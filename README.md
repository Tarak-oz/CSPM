# Azure Landing Zone (simplified, single subscription)

Two equivalent implementations of a simplified, single-subscription Azure
landing zone:

- `terraform/` - Terraform implementation using the `azurerm` provider
- `bicep/` - Bicep implementation, subscription-scoped deployment

Both create: hub + spoke resource groups (plus a shared RG), a hub VNet and
spoke VNet each with an NSG, bidirectional VNet peering, two subscription
Azure Policy assignments (allowed locations, mandatory tag), and optional
RBAC role assignments. See each folder's README for usage.

Out of scope: management group hierarchy / multi-subscription
enterprise-scale design, Azure Firewall/VPN/ExpressRoute, and the full ALZ
policy initiative.
