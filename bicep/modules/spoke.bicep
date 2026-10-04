@description('Base name used to derive resource names.')
param name string

@description('Azure region for the spoke VNet.')
param location string

@description('Tags applied to all resources.')
param tags object

param spokeAddressSpace string
param spokeSubnetPrefix string

@description('Resource ID of the hub VNet, used for the reverse peering.')
param hubVnetId string

resource spokeNsg 'Microsoft.Network/networkSecurityGroups@2023-09-01' = {
  name: 'nsg-${name}-spoke'
  location: location
  tags: tags
}

resource spokeVnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: 'vnet-${name}-spoke'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        spokeAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-${name}-spoke'
        properties: {
          addressPrefix: spokeSubnetPrefix
          networkSecurityGroup: {
            id: spokeNsg.id
          }
        }
      }
    ]
  }
}

resource spokeToHubPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-09-01' = {
  parent: spokeVnet
  name: 'peer-spoke-to-hub'
  properties: {
    remoteVirtualNetwork: {
      id: hubVnetId
    }
    allowForwardedTraffic: true
    allowVirtualNetworkAccess: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
}

output spokeVnetId string = spokeVnet.id
