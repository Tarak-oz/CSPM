# Bicep Azure Landing Zone (simplified, single subscription)

Subscription-scoped deployment that mirrors the Terraform implementation in
`../terraform`:

- Three resource groups: hub, spoke, shared
- A hub VNet and a spoke VNet, each with one subnet and an NSG
- VNet peering between hub and spoke (bidirectional)
- Two subscription-level Azure Policy assignments: allowed locations and a
  mandatory tag (built-in policy definitions)
- Optional RBAC role assignments at subscription scope via
  `rbacAssignments` (value needs `principalId` and the role definition GUID
  as `roleDefinitionId`)

## Usage

```bash
az deployment sub create \
  --location westeurope \
  --template-file bicep/main.bicep \
  --parameters bicep/main.bicepparam
```

No tenant or subscription IDs are hardcoded; the deployment targets the
subscription of the authenticated `az` context.

## Structure

- `main.bicep` - subscription-scope entry point, resource groups, module wiring
- `modules/networking.bicep` - hub VNet/NSG, invokes spoke module, hub->spoke peering
- `modules/spoke.bicep` - spoke VNet/NSG and spoke->hub peering
- `modules/policy.bicep` - policy assignments at subscription scope
- `modules/rbac.bicep` - optional RBAC assignments at subscription scope
- `main.bicepparam` - sample parameter file

## Out of scope

Management group hierarchy, multi-subscription enterprise-scale design,
Azure Firewall/VPN/ExpressRoute, and the full ALZ policy initiative are not
included. This is a minimal, single-subscription starting point.
