# Terraform Azure Landing Zone (simplified, single subscription)

This module creates a simplified single-subscription landing zone:

- Three resource groups: hub, spoke, shared
- A hub VNet and a spoke VNet, each with one subnet and an NSG
- VNet peering between hub and spoke
- Two subscription-level Azure Policy assignments: allowed locations and a mandatory tag
- Optional RBAC role assignments at subscription scope via `var.rbac_assignments`

## Usage

```bash
cd terraform
terraform init
terraform plan -var="location=westeurope" -var="prefix=contoso"
```

No tenant or subscription IDs are hardcoded. Authentication uses the ambient
Azure CLI / service principal context picked up by the `azurerm` provider.

## Structure

- `providers.tf` - provider and version pinning
- `variables.tf` - all configurable inputs with defaults
- `main.tf` - resource groups, networking, peering, policy, RBAC
- `outputs.tf` - IDs/names useful to downstream consumers

## Out of scope

Management group hierarchy, multi-subscription enterprise-scale design,
Azure Firewall/VPN/ExpressRoute, and the full ALZ policy initiative are not
included. This is a minimal, single-subscription starting point.
