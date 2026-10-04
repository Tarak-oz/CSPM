@description('Base name used to derive resource names.')
param name string

@description('Azure region for networking resources.')
param location string

@description('Tags applied to all resources.')
param tags object

@description('Name of the resource group where the spoke VNet is deployed.')
param spokeResourceGroupName string

@description('Unused here except to document hub RG scope; module is deployed scoped to the hub RG.')
param hubResourceGroupName string

param hubAddressSpace string
param hubSubnetPrefix string
param spokeAddressSpace string
param spokeSubnetPrefix string

resource hubNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-${name}-hub'
  location: location
  tags: tags
}

resource hubVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-${name}-hub'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        hubAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-${name}-hub'
        properties: {
          addressPrefix: hubSubnetPrefix
          networkSecurityGroup: {
            id: hubNsg.id
          }
        }
      }
    ]
  }
}

module spoke 'spoke.bicep' = {
  name: 'spoke-networking'
  scope: resourceGroup(spokeResourceGroupName)
  params: {
    name: name
    location: location
    tags: tags
    spokeAddressSpace: spokeAddressSpace
    spokeSubnetPrefix: spokeSubnetPrefix
    hubVnetId: hubVnet.id
  }
}

resource hubToSpokePeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: hubVnet
  name: 'peer-hub-to-spoke'
  properties: {
    remoteVirtualNetwork: {
      id: spoke.outputs.spokeVnetId
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output hubVnetId string = hubVnet.id
output spokeVnetId string = spoke.outputs.spokeVnetId
