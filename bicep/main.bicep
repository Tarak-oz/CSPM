targetScope = 'subscription'

@description('Naming prefix applied to all resources in this landing zone.')
param prefix string = 'lz'

@description('Azure region for all resources.')
param location string = 'westeurope'

@description('Environment tag/suffix (e.g. dev, test, prod).')
param environment string = 'dev'

@description('Address space for the hub VNet.')
param hubAddressSpace string = '10.0.0.0/16'

@description('Subnet prefix inside the hub VNet.')
param hubSubnetPrefix string = '10.0.1.0/24'

@description('Address space for the spoke VNet.')
param spokeAddressSpace string = '10.1.0.0/16'

@description('Subnet prefix inside the spoke VNet.')
param spokeSubnetPrefix string = '10.1.1.0/24'

@description('Locations allowed by the allowed-locations policy assignment.')
param allowedLocations array = [
  'westeurope'
  'northeurope'
]

@description('Tag name enforced by the require-tag policy assignment.')
param mandatoryTagName string = 'CostCenter'

@description('RBAC role assignments to create at subscription scope. Key is an arbitrary name.')
param rbacAssignments object = {}

@description('Common tags applied to all resources.')
param tags object = {
  managedBy: 'bicep'
}

var name = '${prefix}-${environment}'
var resourceTags = union(tags, { environment: environment })

resource rgHub 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${name}-hub'
  location: location
  tags: resourceTags
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${name}-spoke'
  location: location
  tags: resourceTags
}

resource rgShared 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: 'rg-${name}-shared'
  location: location
  tags: resourceTags
}

module networking 'modules/networking.bicep' = {
  name: 'networking'
  scope: resourceGroup(rgHub.name)
  params: {
    name: name
    location: location
    tags: resourceTags
    hubResourceGroupName: rgHub.name
    spokeResourceGroupName: rgSpoke.name
    hubAddressSpace: hubAddressSpace
    hubSubnetPrefix: hubSubnetPrefix
    spokeAddressSpace: spokeAddressSpace
    spokeSubnetPrefix: spokeSubnetPrefix
  }
  dependsOn: [
    rgSpoke
  ]
}

module policy 'modules/policy.bicep' = {
  name: 'policy'
  params: {
    environment: environment
    allowedLocations: allowedLocations
    mandatoryTagName: mandatoryTagName
  }
}

module rbac 'modules/rbac.bicep' = {
  name: 'rbac'
  params: {
    rbacAssignments: rbacAssignments
  }
}

output hubResourceGroupName string = rgHub.name
output spokeResourceGroupName string = rgSpoke.name
output sharedResourceGroupName string = rgShared.name
output hubVnetId string = networking.outputs.hubVnetId
output spokeVnetId string = networking.outputs.spokeVnetId
